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

resource "aws_key_pair" "auth" {
  key_name   = "${var.name_prefix}-pub-key"
  public_key = file(var.pub_key)
}

resource "aws_instance" "wireguard" {
  ami           = data.aws_ami.latest_ubuntu.id
  instance_type = "t3a.micro"
  tags          = { "Name" = "${var.name_prefix}-vpn" }

  vpc_security_group_ids = [aws_security_group.wireguard.id]

  user_data = templatefile("resources/cloud-init.yaml.tpl", { public_port = random_integer.public_port.result })
}
