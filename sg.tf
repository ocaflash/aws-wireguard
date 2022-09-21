resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_security_group" "wireguard" {
  name        = "${var.name_prefix}-sg-vpn"
  description = "Wireguard security group"
  vpc_id      = aws_default_vpc.default.id

  tags = {
    "Name"         = "${var.name_prefix} TCP/UDP Access"
    "Project UUID" = "${random_id.project_uuid.hex}"
  }

  ingress {
    protocol    = "udp"
    from_port   = random_integer.client_port.result
    to_port     = random_integer.client_port.result
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = random_integer.web_port.result
    to_port     = random_integer.web_port.result
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
