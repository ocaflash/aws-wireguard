resource "aws_s3_bucket" "backup" {
  bucket = "${var.name_prefix}-backup-${random_id.project_uuid.hex}"

  tags = {
    "Name"         = "${var.name_prefix}-backup-${random_id.project_uuid.hex}"
    "Project UUID" = "${random_id.project_uuid.hex}"
  }
}

resource "aws_s3_bucket_acl" "private" {
  bucket = aws_s3_bucket.backup.id
  acl    = "private"
}
