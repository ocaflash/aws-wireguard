output "management_dashboard" {
  description = "Management Dashboard URI"
  value       = format("http://%s:%s", aws_eip.wireguard.public_ip, random_integer.web_port.result)
}

output "project_uuid" {
  description = "Tag Project UUID"
  value       = random_id.project_uuid.hex
}

output "web_admin_name" {
  description = "User Dashboard Name admin's"
  value       = var.web_admin_name
}

output "web_admin_pass" {
  description = "User Dashboard Password admin's"
  value       = random_password.web_admin_pass.result
  sensitive   = true
}

output "comment_password" {
  value = "print 'terraform output -json' to view web_admin_pass"

}
