resource "random_integer" "public_port" {
  min = 1000
  max = 9999
}
