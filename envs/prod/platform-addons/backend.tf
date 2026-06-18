terraform {
  backend "s3" {
    # 제공한 Terraform state 저장용 S3 bucket입니다.
    bucket = "tfstate-lionkdt5-team6"

    # 환경 x 레이어별로 state 파일 경로를 분리합니다.
    # 예: dev/infra, dev/platform-addons, prod/infra, prod/platform-addons
    key = "prod/platform-addons/terraform.tfstate"

    # 서울 리전 사용
    region = "ap-northeast-2"

    # S3에 저장되는 state 파일 암호화
    encrypt = true

    # Terraform 1.10+ S3 native lock 기능입니다.
    # DynamoDB lock table을 따로 만들 필요가 없습니다.
    use_lockfile = true
  }
}
