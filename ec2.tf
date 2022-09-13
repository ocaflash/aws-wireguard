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

resource "tls_private_key" "ssh" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "auth" {
  key_name   = "${var.name_prefix}-key"
  public_key = tls_private_key.ssh.public_key_openssh
}

resource "local_file" "ssh_key_private" {
  content         = tls_private_key.ssh.private_key_openssh
  filename        = aws_key_pair.auth.key_name
  file_permission = "0600"
}

data "template_file" "backup" {
  template = file("resources/backup.sh.tpl")
  vars = {
    name_prefix  = var.name_prefix,
    project_uuid = random_id.project_uuid.hex
  }
}

data "template_file" "setup_config" {
  template = file("resources/setup_config.py.tpl")
  vars = {
    ipv4_address   = var.ip_address_int,
    client_port    = random_integer.client_port.result,
    web_admin_name = var.web_admin_name,
  }
}

resource "aws_instance" "wireguard" {
  ami                  = data.aws_ami.latest_ubuntu.id
  instance_type        = "t3a.micro"
  key_name             = aws_key_pair.auth.id
  iam_instance_profile = aws_iam_instance_profile.ec2_s3_role.name
  tags = {
    "Name"         = "${var.name_prefix} VPN Instance"
    "Project UUID" = "${random_id.project_uuid.hex}"
  }

  vpc_security_group_ids = [aws_security_group.wireguard.id]

  user_data = templatefile("resources/cloud-init.yaml.tpl",
    { web_port     = random_integer.web_port.result,
      client_port  = random_integer.client_port.result,
      project_uuid = random_id.project_uuid.hex,
      name_prefix  = var.name_prefix,
    ssh_public_key = tls_private_key.ssh.public_key_openssh }
  )

  connection {
    host        = self.public_ip
    type        = "ssh"
    user        = var.ssh_user
    private_key = file("${aws_key_pair.auth.key_name}")
    agent       = false
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "echo Done!",
      "sudo mkdir -p /home/${var.ssh_user}/wireguard/scripts/ && sudo chown -R ${var.ssh_user}: /home/${var.ssh_user}/wireguard/scripts/",
      "sudo mkdir -p /home/${var.ssh_user}/wireguard/linguard/data && sudo chown -R ${var.ssh_user}: /home/${var.ssh_user}/wireguard/linguard/data/"
    ]
  }

  provisioner "file" {
    content     = data.template_file.backup.rendered
    destination = "/home/${var.ssh_user}/wireguard/scripts/backup.sh"
  }

  provisioner "file" {
    source      = "resources/setup_backup.sh.tpl"
    destination = "/home/${var.ssh_user}/wireguard/scripts/setup_backup.sh"
  }

  provisioner "file" {
    source      = "resources/run_setup_config.sh.tpl"
    destination = "/home/${var.ssh_user}/wireguard/scripts/run_setup_config.sh"
  }

  provisioner "file" {
    content     = data.template_file.setup_config.rendered
    destination = "/home/${var.ssh_user}/wireguard/scripts/setup_config.py"
  }

  provisioner "file" {
    source      = "resources/users.csv"
    destination = "/home/${var.ssh_user}/wireguard/linguard/data/users.csv"
  }
}
