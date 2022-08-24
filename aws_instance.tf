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

data "template_file" "wireguard_userdata" {
  template = file("resources/cloud-init.yaml.tpl")

  vars = {
    public_port = random_integer.public_port.result
  }
}

resource "aws_instance" "wireguard" {
  ami           = data.aws_ami.latest_ubuntu.id
  instance_type = "t3a.micro"

  vpc_security_group_ids = [aws_security_group.wireguard.id]

  user_data = data.template_file.wireguard_userdata.rendered
}
