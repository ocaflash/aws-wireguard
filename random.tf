resource "random_integer" "public_port" {
  min = 1000
  max = 9999
}

resource "random_id" "project_uuid" {
  byte_length = 8
}
