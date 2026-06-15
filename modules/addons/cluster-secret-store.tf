# -------------------------------------------------------------------
# ClusterSecretStore
# -------------------------------------------------------------------
#
# ESO가 AWS Secrets Manager에서 시크릿을 읽어올 때 사용하는
# 클러스터 전체 공유 시크릿 스토어입니다.
#
# 연결 구조:
#
# ExternalSecret (nowait-dev namespace)
#   ↓
# ClusterSecretStore (cluster-wide)
#   ↓
# ESO Pod Identity Association
#   ↓
# team6-nowait-dev-eso-role
#   ↓
# AWS Secrets Manager
# -------------------------------------------------------------------
resource "kubernetes_manifest" "cluster_secret_store" {
  count = var.enable_eso_pod_identity ? 1 : 0

  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ClusterSecretStore"
    metadata = {
      name = "team6-nowait-cluster-secret-store"
      labels = {
        team = var.team
      }
    }
    spec = {
      provider = {
        aws = {
          service = "SecretsManager"
          region  = var.region
          auth = {
            jwt = {
              serviceAccountRef = {
                name      = local.eso_service_account
                namespace = local.eso_namespace
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    helm_release.eso,
    aws_eks_pod_identity_association.eso
  ]
}