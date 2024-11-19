data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_s3_role" {
  name                = var.iam_role_name
  path                = var.iam_role_path
  assume_role_policy  = data.aws_iam_policy_document.ec2_assume_role.json
  managed_policy_arns = concat(var.iam_role_policy_attachment, ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"])
}

resource "aws_iam_instance_profile" "ec2_s3_role" {
  name = var.iam_role_name
  role = aws_iam_role.ec2_s3_role.name
}
