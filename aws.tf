terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  # backend "s3" {
  #   bucket = "terraform-s3-backend-"
  #   key    = "global/s3/terraform.tfstate"
  #   region = var.region
  # }
}

provider "aws" {
  region = var.region
}
