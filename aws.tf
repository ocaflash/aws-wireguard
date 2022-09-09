terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.20"
    }
  }
  backend "s3" {
    encrypt = true
    bucket  = "s3-state-vdj907fr65kxxdzj"
    key     = "terraform-state/terraform.tfstate"
    region  = "us-west-2"
  }
}

provider "aws" {
  region = var.region
}
