provider "aws" {
  region = var.region

  # 모든 AWS 리소스에 Team=team6 태그를 자동 적용합니다.
  default_tags {
    tags = local.default_tags
  }
}

# 이미 생성된 EKS Cluster 정보를 조회합니다.
# platform-addons는 infra가 만든 EKS 위에 설치되므로 data source를 사용합니다.
data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

# Terraform이 EKS에 접근하기 위한 인증 토큰을 가져옵니다.
data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name
}

# Kubernetes provider 설정입니다.
# namespace, serviceAccount, secretStore 같은 Kubernetes 리소스 관리에 사용합니다.
provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

# Helm provider 설정입니다.
# ALB Controller, ArgoCD, metrics-server, ESO 같은 Helm chart 설치에 사용합니다.
provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}
