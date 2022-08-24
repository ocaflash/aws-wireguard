resource "random_integer" "public_port" {
  min = 1000
  max = 9999
}

resource "random_id" "project_uuid" {
  keepers = {
    ami_id = data.aws_ami.latest_ubuntu.id
  }
  byte_length = 8
}
