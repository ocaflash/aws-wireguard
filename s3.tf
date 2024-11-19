resource "aws_s3_bucket" "backup" {
  bucket = "${var.name_prefix}-backup-${random_id.project_uuid.hex}"

  tags = {
    "Name" = "${var.name_prefix}-backup-${random_id.project_uuid.hex}"
  }
}

resource "aws_s3_bucket_ownership_controls" "backup" {
  bucket = aws_s3_bucket.backup.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "private" {
  depends_on = [aws_s3_bucket_ownership_controls.backup]

  bucket = aws_s3_bucket.backup.id
  acl    = "private"
}