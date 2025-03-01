terraform {
  required_version = ">= 1.9.4"
  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.2"
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

  default_tags {
    tags = {
      Project     = "WireGuard VPN"
      ProjectUUID = random_id.project_uuid.hex
    }
  }
}
