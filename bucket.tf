resource "aws_s3_bucket" "backup" {
  bucket = "${var.name_prefix}-bucket-vpn"
}

resource "aws_s3_bucket_acl" "private" {
  bucket = aws_s3_bucket.backup.id
  acl    = "private"
}
