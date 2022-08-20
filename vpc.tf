
# resource "aws_vpc" "wireguard-vpc" {
#   cidr_block           = var.vpc_cidr_block
#   enable_dns_hostnames = true
# }
#
# ## Public
# resource "aws_subnet" "subnet-public" {
#   vpc_id            = aws_vpc.wireguard-vpc.id
#   cidr_block        = var.public_subnets_cidrs[0]
#   availability_zone = var.availability_zones[0]
#   tags = {
#     Name = "Public network"
#   }
# }
#
# ## Private
# resource "aws_subnet" "subnet-private" {
#   vpc_id            = aws_vpc.wireguard-vpc.id
#   cidr_block        = var.private_subnets_cidrs[0]
#   availability_zone = var.availability_zones[0]
#   tags = {
#     Name = "Private network"
#   }
# }
#
# #Internet  GW
# resource "aws_internet_gateway" "wireguard" {
#   vpc_id = aws_vpc.wireguard-vpc.id
# }
