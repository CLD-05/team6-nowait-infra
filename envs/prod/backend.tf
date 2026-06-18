terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket  = "tfstate-lionkdt5-team6"
    key     = "prod/network/terraform.tfstate"
    region  = "ap-northeast-2"
    encrypt = true
  }
}
