# -------------------------------------------------------------------
# ClusterSecretStore
# -------------------------------------------------------------------
#
# External Secrets Operator가 AWS Secrets Manager에서 시크릿을 읽어올 때 사용하는
# 클러스터 전체 공유 SecretStore입니다.
#
# 인증은 EKS Pod Identity Association을 통해 ESO Pod에 연결된 IAM Role을 사용합니다.
# 따라서 IRSA 방식의 auth.jwt.serviceAccountRef는 사용하지 않습니다.
# -------------------------------------------------------------------
resource "kubernetes_manifest" "cluster_secret_store" {
  count = var.enable_eso_pod_identity ? 1 : 0

  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ClusterSecretStore"

    metadata = {
      name = "team6-nowait-cluster-secret-store"

      labels = {
        team        = var.team
        project     = var.project
        environment = var.environment
      }
    }

    spec = {
      provider = {
        aws = {
          service = "SecretsManager"
          region  = var.region
        }
      }
    }
  }

  depends_on = [
    helm_release.eso,
    aws_eks_pod_identity_association.eso
  ]
}