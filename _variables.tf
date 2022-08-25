variable "name_prefix" {
  description = "Prefix to be used in the naming of some of the created AWS resources"
  default     = "wireguard"
}

variable "region" {
  description = "Region to be used for AWS resources"
  default     = "us-west-2"
}

variable "iam-role-name" {
  type        = string
  description = "IAM role name"
  default     = "ec2-admin-role"
}

variable "iam-role-path" {
  type        = string
  description = "IAM role path"
  default     = "/"
}

variable "iam-role-policy-attachment" {
  type        = list(string)
  description = "List of IAM policies"
  default = [
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  ]
}
