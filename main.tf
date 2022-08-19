# module "networking" {
#   source  = "cn-terraform/networking/aws"
#   version = "2.0.13"
#
#   name_prefix = substr(format("%s-%s", var.name_prefix, var.environment), 0, 32)
#
#   vpc_cidr_block                              = var.vpc_cidr_block
#   availability_zones                          = var.availability_zones
#   public_subnets_cidrs_per_availability_zone  = var.public_subnets_cidrs
#   private_subnets_cidrs_per_availability_zone = var.private_subnets_cidrs
#   single_nat                                  = true
# }

resource "aws_security_group" "wireguard" {
  name        = "${var.name_prefix}-${var.environment}-vpn"
  description = "Communication to and from VPC endpoint"
  # vpc_id      = module.networking.vpc_id

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

data "template_file" "wireguard_userdata" {
  template = file("resources/cloud-init.yaml")
}

resource "aws_instance" "wireguard" {
  ami           = "ami-0fb653ca2d3203ac1"
  instance_type = "t3a.micro" #"t3a.nano"
  key_name      = aws_key_pair.ssh_key.key_name
  # subnet_id              = module.networking.public_subnets_ids[0]
  vpc_security_group_ids = [aws_security_group.wireguard.id]
  user_data              = data.template_file.wireguard_userdata.rendered

  tags = {
    Name = "${var.name_prefix}-${var.environment}"
  }
}

resource "aws_key_pair" "ssh_key" {
  key_name   = format("%s-wg-server-ssh-key", var.environment)
  public_key = var.ssh_public_key
}
