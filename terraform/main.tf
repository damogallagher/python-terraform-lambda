terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.48.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
    arch    ive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
  }

  required_version = "~> 1.0"
}

provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = var.code_s3_bucket_name

  acl           = "private"
  force_destroy = true
}


data "archive_file" "minimal_lambda_function" {
  type = "zip"

  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_s3_bucket_object" "minimal_lambda_function" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "lambda.zip"
  source = data.archive_file.minimal_lambda_function.output_path

  etag = filemd5(data.archive_file.minimal_lambda_function.output_path)
}