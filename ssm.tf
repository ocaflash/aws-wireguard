resource "aws_ssm_document" "wireguard_reset_password" {
  name          = "${var.name_prefix}-reset-password"
  document_type = "Command"

  content = jsonencode({
    schemaVersion = "2.2"
    description   = "Reset Wireguard Admin Password"
    parameters    = {}
    mainSteps = [
      {
        action = "aws:runShellScript",
        name   = "resetPassword",
        inputs = {
          runCommand = [
            "rm -f /home/wguser/wireguard/linguard/data/.credentials",
            "docker restart linguard"
          ]
        }
      }
    ]
  })
}

resource "aws_ssm_association" "wireguard_reset_password_association" {
  name = aws_ssm_document.wireguard_reset_password.name

  targets {
    key    = "tag:Project UUID"
    values = [random_id.project_uuid.hex]
  }

  targets {
    key    = "tag:Name"
    values = ["${var.name_prefix} VPN Instance"]
  }

  automation_target_parameter_name = "InstanceId"
  max_concurrency                 = "1"
  max_errors                      = "0"
}