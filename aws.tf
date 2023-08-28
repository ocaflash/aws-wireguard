terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket = "wireguard-tfstate-3f1a86f1"
    key    = "wireguard/terraform.tfstate"
    region = "eu-central-1"
  }
}

provider "aws" {
  region = var.region
}
