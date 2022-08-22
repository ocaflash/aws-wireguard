resource "aws_eip" "wireguard" {
  vpc  = true
  tags = merge(var.tags, { "Name" = "${var.name_prefix}-eip" })
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "wireguard" {
  name        = "${var.name_prefix}-sg-vpn"
  description = "Communication to and from VPC endpoint"

  tags = {
    Name = "${var.name_prefix}-sg-vpn"
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

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.wireguard.id
  allocation_id = aws_eip.wireguard.id
}
