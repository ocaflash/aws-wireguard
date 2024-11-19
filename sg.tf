resource "aws_security_group" "wireguard" {
  name        = "${var.name_prefix}-sg-vpn"
  description = "Wireguard security group"

  ingress {
    protocol    = "udp"
    from_port   = random_integer.client_port.result
    to_port     = random_integer.client_port.result
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = random_integer.dashboard_port.result
    to_port     = random_integer.dashboard_port.result
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
