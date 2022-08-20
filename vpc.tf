
resource "aws_vpc" "wireguard-vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
}

## Public
resource "aws_subnet" "subnet-public" {
  vpc_id            = aws_vpc.wireguard-vpc.id
  cidr_block        = var.public_subnets_cidrs[0]
  availability_zone = var.availability_zones
  tags = {
    Name = "Public network"
  }
}

## Private
resource "aws_subnet" "subnet-private" {
  vpc_id            = aws_vpc.wireguard-vpc.id
  cidr_block        = var.private_subnets_cidrs[0]
  availability_zone = var.availability_zones
  tags = {
    Name = "Private network"
  }
}

#Internet  GW
resource "aws_internet_gateway" "wireguard" {
  vpc_id = aws_vpc.wireguard_vpc.id
}

resource "aws_security_group" "wireguard" {
  name        = "${var.name_prefix}-${var.environment}-vpn"
  description = "Communication to and from VPC endpoint"
  vpc_id      = aws_vpc.wireguard_vpc.id

  tags = {
    Name = "${var.name_prefix}-${var.environment}"
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "udp"
    from_port   = 51820
    to_port     = 51820
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 8080
    to_port     = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }

  ##################
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "wireguard" {
  instance = aws_instance.wireguard.id
  vpc      = true
}

resource "aws_eip_association" "wireguard" {
  instance_id   = aws_instance.wireguard.id
  allocation_id = aws_eip.wireguard.id
}
