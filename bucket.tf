resource "aws_s3_bucket" "backup" {
  bucket = "${var.name_prefix}-s3_bucket-vpn"
  acl    = "private"

  versioning {
    enabled = true
  }
}
