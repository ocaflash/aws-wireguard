resource "aws_eip" "wireguard" {
  instance = aws_instance.wireguard.id

  # lifecycle {
  #   prevent_destroy = true
  # }
}
