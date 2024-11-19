data "aws_ami" "latest_ubuntu" {
  owners      = ["099720109477"]
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-*-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_instance" "wireguard" {
  ami                  = data.aws_ami.latest_ubuntu.id
  instance_type        = "t3a.micro"
  iam_instance_profile = aws_iam_instance_profile.ec2_s3_role.name

  vpc_security_group_ids = [aws_security_group.wireguard.id]

  user_data = templatefile("resources/cloud-init.yaml.tpl",
    { dashboard_port = random_integer.dashboard_port.result,
      client_port    = random_integer.client_port.result,
      project_uuid   = random_id.project_uuid.hex,
      uuid_interface = random_id.uuid_interface.hex,
      name_prefix    = var.name_prefix,
      ipv4_address   = var.ip_address_int
    }
  )
}
