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


data "template_file" "wireguard_userdata" {
  template = file("resources/cloud-init.yaml")
}

resource "aws_instance" "wireguard" {
  ami           = data.aws_ami.latest_ubuntu.id
  instance_type = "t3a.micro" #"t3a.nano"
  key_name      = aws_key_pair.ssh_key.key_name
  subnet_id     = aws_subnet.subnet-public.public_subnets_ids[0]
  # subnet_id                   = module.networking.public_subnets_ids[0]
  vpc_security_group_ids      = [aws_security_group.wireguard.id]
  associate_public_ip_address = true
  user_data                   = data.template_file.wireguard_userdata.rendered

  tags = {
    Name = "${var.name_prefix}-${var.environment}"
  }
}

resource "aws_key_pair" "ssh_key" {
  key_name   = format("%s-wg-server-ssh-key", var.environment)
  public_key = file(var.ssh_public_key)
}
