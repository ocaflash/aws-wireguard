data "template_file" "wireguard_userdata" {
  template = file("resources/cloud-init.yaml")
}

resource "aws_instance" "wireguard" {
  ami                         = data.aws_ami.latest_ubuntu.id
  instance_type               = "t3a.micro"
  vpc_security_group_ids      = [aws_security_group.wireguard.id]
  associate_public_ip_address = true
  user_data                   = data.template_file.wireguard_userdata.rendered

  tags = {
    Name = "${var.name_prefix}-vpn"
  }
}

resource "aws_eip_association" "wireguard" {
  instance_id   = aws_instance.wireguard.id
  allocation_id = aws_eip.wireguard.id
}
