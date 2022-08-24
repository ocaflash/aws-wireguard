output "management_dashboard" {
  description = "Management Dashboard URI"
  value       = format("http://%s:%s", aws_eip.wireguard.public_ip, random_integer.public_port.result)
}
