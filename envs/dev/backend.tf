terraform {
  backend "s3" {
    bucket         = "team6-nowait-infra-tfstate-dev" # AWS 콘솔에서 수동 생성할 S3 버킷명
    key            = "dev/terraform.tfstate"         # 버킷 내 저장될 경로
    region         = "ap-northeast-2"                # 서울 리전
    dynamodb_table = "team6-nowait-infra-tflock-dev"   # AWS 콘솔에서 수동 생성할 DynamoDB 테이블명
    encrypt        = true
  }
}