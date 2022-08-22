variable "name_prefix" {
  description = "Prefix to be used in the naming of some of the created AWS resources"
  default     = "wireguard"
}

variable "region" {
  description = "Region to be used for AWS resources"
  default     = "us-west-2"
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "aws_access_key" {}
variable "aws_secret_key" {}
