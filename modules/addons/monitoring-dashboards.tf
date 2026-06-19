# -------------------------------------------------------------------
# NoWait 커스텀 Grafana 대시보드
#
# kube-prometheus-stack은 grafana_dashboard=1 라벨이 붙은 ConfigMap을
# 전체 네임스페이스에서 watch하는 사이드카(k8s-sidecar)를 같이 띄운다.
# 그 라벨만 붙이면 별도 Grafana API 호출 없이 자동으로 로드된다.
# -------------------------------------------------------------------
resource "kubernetes_config_map" "nowait_grafana_dashboard" {
  count = var.enable_kube_prometheus_stack && var.nowait_dashboard_json_file != null ? 1 : 0

  metadata {
    name      = "nowait-grafana-dashboard"
    namespace = "monitoring"
    labels = {
      grafana_dashboard = "1"
    }
  }

  data = {
    "nowait-overview.json" = file(var.nowait_dashboard_json_file)
  }

  depends_on = [
    helm_release.kube_prometheus_stack
  ]
}

# -------------------------------------------------------------------
# NoWait 핵심 운영 대시보드 (NoWait 핵심 운영 대시보드 / uid=nowait-core-ops)
#
# 위 nowait-overview 와 동일한 방식(grafana_dashboard=1 라벨 ConfigMap → 사이드카 자동 로드)으로
# 추가 제공한다. Grafana API 로 직접 만든 대시보드는 grafana persistence(emptyDir)라서
# 파드 재시작 시 사라지므로, ConfigMap 으로 영구 관리한다.
# -------------------------------------------------------------------
resource "kubernetes_config_map" "nowait_core_ops_dashboard" {
  count = var.enable_kube_prometheus_stack && var.nowait_core_dashboard_json_file != null ? 1 : 0

  metadata {
    name      = "nowait-core-ops-dashboard"
    namespace = "monitoring"
    labels = {
      grafana_dashboard = "1"
    }
  }

  data = {
    "nowait-core-ops.json" = file(var.nowait_core_dashboard_json_file)
  }

  depends_on = [
    helm_release.kube_prometheus_stack
  ]
}
