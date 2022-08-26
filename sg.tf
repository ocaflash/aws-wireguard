resource "aws_security_group" "wireguard" {
  name        = "${var.name_prefix}-sg-vpn"
  description = "Wireguard security group"

  tags = {
    "Name"         = "${var.name_prefix} TCP/UDP Access"
    "Project UUID" = "${random_id.project_uuid.hex}"
  }

  ingress {
    protocol    = "udp"
    from_port   = 51820
    to_port     = 51820
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = random_integer.public_port.result
    to_port     = random_integer.public_port.result
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
