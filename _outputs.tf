output "management_dashboard" {
  description = "Management Dashboard URI"
  value       = format("http://%s:%s", aws_eip.wireguard.public_ip, random_integer.web_port.result)
}

output "project_uuid" {
  description = "Tag Project UUID"
  value       = random_id.project_uuid.hex
}
