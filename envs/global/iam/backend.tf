terraform {
  backend "s3" {
    bucket = "tfstate-lionkdt5-team6"
    key    = "global/iam/terraform.tfstate"
    region = "ap-northeast-2"

    encrypt      = true
    use_lockfile = true
  }
}