# -------------------------------------------------------------------
# redis_exporter — ElastiCache(team6-nowait-dev-redis) 메트릭 수집기
#
# Redis/ElastiCache 는 AWS 관리형이라 Prometheus 가 직접 스크랩할 수 없으므로
# 클러스터 내부에 redis_exporter 를 띄워 ElastiCache 엔드포인트에 접속하고,
# kube-prometheus-stack 이 ServiceMonitor(release=kube-prometheus-stack 라벨)로 스크랩한다.
# 제공 메트릭: redis_up, redis_memory_used_bytes, redis_memory_max_bytes, redis_evicted_keys_total 등.
# (dev ElastiCache 는 TLS/AUTH 미사용)
# -------------------------------------------------------------------
locals {
  redis_exporter_enabled = var.enable_kube_prometheus_stack && var.enable_redis_exporter && var.redis_exporter_redis_address != null
  redis_exporter_labels = {
    app  = "redis-exporter"
    team = var.team
  }
}

resource "kubernetes_deployment" "redis_exporter" {
  count = local.redis_exporter_enabled ? 1 : 0

  metadata {
    name      = "redis-exporter"
    namespace = var.redis_exporter_namespace
    labels    = local.redis_exporter_labels
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "redis-exporter"
      }
    }

    template {
      metadata {
        labels = local.redis_exporter_labels
      }

      spec {
        container {
          name  = "redis-exporter"
          image = var.redis_exporter_image
          args  = ["--redis.addr=${var.redis_exporter_redis_address}"]

          port {
            name           = "redis-metrics"
            container_port = 9121
          }

          dynamic "env" {
            for_each = var.redis_exporter_password_secret_name != null ? [1] : []
            content {
              name = "REDIS_PASSWORD"
              value_from {
                secret_key_ref {
                  name = var.redis_exporter_password_secret_name
                  key  = var.redis_exporter_password_secret_key
                }
              }
            }
          }

          dynamic "env" {
            for_each = var.redis_exporter_tls_skip_verify ? [1] : []
            content {
              name  = "REDIS_EXPORTER_TLS_CLIENT_INSECURE_SKIP_VERIFY"
              value = "true"
            }
          }

          resources {
            requests = {
              cpu    = "10m"
              memory = "32Mi"
            }
            limits = {
              cpu    = "100m"
              memory = "128Mi"
            }
          }

          security_context {
            run_as_non_root            = true
            run_as_user                = 59000
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
            capabilities {
              drop = ["ALL"]
            }
          }
        }
      }
    }
  }

  depends_on = [
    helm_release.kube_prometheus_stack
  ]
}

resource "kubernetes_service" "redis_exporter" {
  count = local.redis_exporter_enabled ? 1 : 0

  metadata {
    name      = "redis-exporter"
    namespace = var.redis_exporter_namespace
    labels    = local.redis_exporter_labels
  }

  spec {
    selector = {
      app = "redis-exporter"
    }

    port {
      name        = "redis-metrics"
      port        = 9121
      target_port = "redis-metrics"
    }
  }

  depends_on = [
    kubernetes_deployment.redis_exporter
  ]
}

# ServiceMonitor — kube-prometheus-stack 의 serviceMonitorSelector(release=kube-prometheus-stack) 매칭 필요
resource "kubernetes_manifest" "redis_exporter_servicemonitor" {
  count = local.redis_exporter_enabled ? 1 : 0

  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "redis-exporter"
      namespace = var.redis_exporter_namespace
      labels = {
        app     = "redis-exporter"
        team    = var.team
        release = "kube-prometheus-stack"
      }
    }
    spec = {
      selector = {
        matchLabels = {
          app = "redis-exporter"
        }
      }
      namespaceSelector = {
        matchNames = [var.redis_exporter_namespace]
      }
      endpoints = [
        {
          port     = "redis-metrics"
          interval = "30s"
          path     = "/metrics"
        }
      ]
    }
  }

  depends_on = [
    kubernetes_service.redis_exporter
  ]
}
