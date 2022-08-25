resource "aws_eip" "wireguard" {
  instance = aws_instance.wireguard.id
  tags = {
    "Name"         = "${var.name_prefix} Public IP"
    "Project UUID" = "${random_id.project_uuid.hex}"
  }
  # lifecycle {
  #   prevent_destroy = true
  # }
}
