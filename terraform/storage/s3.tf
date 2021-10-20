variable "code_s3_bucket_name" {
  type = string
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = var.code_s3_bucket_name

  acl           = "private"
  force_destroy = true
}

output "src_code_bucket_id" {
  value = aws_s3_bucket.lambda_bucket.id
}
