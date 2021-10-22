variable "aws_region" {
  description = "AWS region for all resources."
  type        = string
  default     = "us-east-1"
}

variable "code_s3_bucket_name" {
  description = "S3 bucket that stores the source code."
  type        = string
  default     = "csx-nonprod-lambda-function-code"
}

variable "lambda_runtime" {
  default = "python3.9"
}

variable "lambda_timeout" {
  default = 60
}

variable "api_gateway_stage" {
  description = "Stage to deploy to on API Gateway."
  type        = string
  default     = "dev"
}

