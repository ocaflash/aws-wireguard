variable "name_prefix" {
  description = "Prefix to be used in the naming of some of the created AWS resources"
  default     = "wireguard"
}

variable "region" {
  description = "Region to be used for AWS resources"
  default     = "ap-south-1"
}

variable "iam_role_name" {
  type        = string
  description = "IAM role name"
  default     = "EC2ToS3Access-wireguard"
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

variable "ssm_access_policy_name" {
  description = "The name of the IAM policy for accessing Parameter Store"
  type        = string
  default     = "SSMAccessPolicy-wireguard"
}

variable "ip_address_int" {
  description = "IP address for Wireguard interface"
  default     = "192.168.10.2"
}