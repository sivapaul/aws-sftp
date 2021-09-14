resource "aws_s3_bucket" "sftp-sftps3" {
  bucket = "dev-dummy-sftp"
  acl    = "private"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

#resource "aws_s3_bucket_policy" "sftp-sftps3" {
#  bucket = aws_s3_bucket.sftp-sftps3.id
#    policy = <<EOF
#{
#    "Version": "2012-10-17",
#    "Statement": [
#        {
#            "Effect": "Allow",
#            "Principal": {
#                "AWS": "arn:aws:iam::${var.account_id}:root"
#            },
#            "Action": "s3:*",
#            "Resource": "arn:aws:s3:::${aws_s3_bucket.sftp-sftps3.bucket_domain_name}/*"
#        }
#    ]
#}
#EOF
#}

resource "aws_s3_bucket_public_access_block" "sftp-policy" {
  bucket = aws_s3_bucket.sftp-sftps3.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}
