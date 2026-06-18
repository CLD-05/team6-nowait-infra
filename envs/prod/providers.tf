provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = "nowait"
      Environment = "prod"
      Team        = "team6"
      ManagedBy   = "terraform"
    }
  }
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = "nowait"
      Environment = "prod"
      Team        = "team6"
      ManagedBy   = "terraform"
    }
  }
}
