data "aws_iam_policy_document" "ec2-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2-s3-role" {
  name                = var.iam_role_name
  path                = var.iam_role_path
  assume_role_policy  = data.aws_iam_policy_document.ec2-assume-role.json
  managed_policy_arns = var.iam_role_policy_attachment
}

resource "aws_iam_instance_profile" "ec2-s3-role" {
  name = var.iam_role_name
  role = aws_iam_role.ec2-s3-role.name
}
