terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.63.0"
    }
    archive = {
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

  source_dir  = "${path.module}/../app"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_s3_bucket_object" "minimal_lambda_function" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "lambda.zip"
  source = data.archive_file.minimal_lambda_function.output_path

  etag = filemd5(data.archive_file.minimal_lambda_function.output_path)
}

resource "aws_lambda_function" "minimal_lambda_function" {
  function_name = "MinimalLambdaFunction"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_bucket_object.minimal_lambda_function.key

  runtime = "${var.lambda_runtime}"
  handler = "${var.lambda_handler}"

  source_code_hash = data.archive_file.minimal_lambda_function.output_base64sha256

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "minimal_lambda_function" {
  name = "/aws/lambda/${aws_lambda_function.minimal_lambda_function.function_name}"

  retention_in_days = 30
}

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}