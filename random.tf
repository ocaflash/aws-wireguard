resource "random_integer" "web_port" {
  min = 1000
  max = 9999
}

resource "random_integer" "client_port" {
  min = 10000
  max = 65536
}

resource "random_id" "project_uuid" {
  byte_length = 8
}
