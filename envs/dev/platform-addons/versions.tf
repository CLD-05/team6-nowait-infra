terraform {
  # Terraform 1.10+ S3 native lock 사용
  required_version = ">= 1.15.3"

  required_providers {
    # AWS IAM Role, EKS Add-on, Pod Identity Association 관리
    aws = {
      source  = "hashicorp/aws"
      version = "6.49.0"
    }

    # Kubernetes 리소스 관리
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
    }

    # Helm chart 설치 관리
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.2"
    }
  }
}