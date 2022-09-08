variable "name_prefix" {
  description = "Prefix to be used in the naming of some of the created AWS resources"
  default     = "wireguard"
}

variable "region" {
  description = "Region to be used for AWS resources"
  default     = "us-west-2"
}

variable "iam_role_name" {
  type        = string
  description = "IAM role name"
  default     = "EC2ToS3Access"
}

variable "iam_role_path" {
  type        = string
  description = "IAM role path"
  default     = "/"
}

variable "iam_role_policy_attachment" {
  type        = list(string)
  description = "List of IAM policies"
  default = [
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  ]
}

variable "ssh_user" {
  description = "SSH user for connect to aws"
  default     = "wguser"
}

variable "ip_address_int" {
  description = "IP address for Wireguard interface"
  default     = "192.168.10.2"
}

variable "web_admin_name" {
  description = "Name admin user for connect to web"
  default     = "admin"
}
