variable "environment" {
  default = "test"
}

variable "name_prefix" {
  description = "Prefix to be used in the naming of some of the created AWS resources"
  default     = "wireguard"
}

variable "region" {
  description = "Region to be used for AWS resources"
  default     = "eu-west-2"
}

variable "availability_zones" {
  description = "Region to be used for AWS resources"
  default     = ["eu-west-2a"]
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "vpc_cidr_block" {
  default = "192.168.0.0/16"
}

variable "public_subnets_cidrs" {
  description = "CIDR for the Public Subnet"
  type        = list(string)
  default     = ["192.168.32.0/19"]
}

variable "private_subnets_cidrs" {
  description = "CIDR for the Private Subnet"
  type        = list(string)
  default     = ["192.168.128.0/19"]
}


variable "ssh_private_key" {}
variable "ssh_public_key" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}
