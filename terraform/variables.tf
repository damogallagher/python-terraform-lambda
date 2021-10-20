variable "aws_region" {
  description = "AWS region for all resources."
  type    = string
  default = "us-east-1"
}

variable "code_s3_bucket_name" {
  description = "S3 bucket that stores the source code."
  type    = string
  default = "csx-lambda-functions-code"
}

