variable "function_name" {
  type = string
}
variable "zip_name" {
  type = string
}
variable "src_code_bucket_id" {
  type = string
}
variable "lambda_runtime" {
  type = string
}
variable "lambda_handler" {
  type = string
}
variable "lambda_timeout" {
  type    = string
  default = 3
}
variable "lambda_function_output_path" {
  type = string
}
variable "lambda_function_base64" {
  type = string
}
variable "lambda_inline_policy" {
  type = string
}
variable "api_gateway_route_key" {
  type = string
}
variable "api_gateway_id" {
  type = string
}
variable "api_gateway_execution_arn" {
  type = string
}

resource "aws_s3_bucket_object" "lambda_function" {
  bucket = var.src_code_bucket_id

  key    = var.zip_name
  source = var.lambda_function_output_path

  etag = filemd5(var.lambda_function_output_path)
}

resource "aws_lambda_function" "lambda_function" {
  function_name = var.function_name

  s3_bucket = var.src_code_bucket_id
  s3_key    = aws_s3_bucket_object.lambda_function.key

  runtime = var.lambda_runtime
  handler = var.lambda_handler
  timeout = var.lambda_timeout

  source_code_hash = var.lambda_function_base64

  role       = aws_iam_role.lambda_exec.arn
  depends_on = [aws_s3_bucket_object.lambda_function]
}

resource "aws_cloudwatch_log_group" "lambda_function" {
  name = "/aws/lambda/${aws_lambda_function.lambda_function.function_name}"

  retention_in_days = 30
}

resource "aws_iam_role" "lambda_exec" {
  name = "${var.function_name}-lambda-role"

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
  inline_policy {
    name = "${var.function_name}-inline-policy"

    policy = var.lambda_inline_policy
  }
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}




resource "aws_apigatewayv2_integration" "lambda_function" {
  api_id = var.api_gateway_id

  integration_uri    = aws_lambda_function.lambda_function.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "lambda_function" {
  api_id = var.api_gateway_id

  route_key = var.api_gateway_route_key
  target    = "integrations/${aws_apigatewayv2_integration.lambda_function.id}"
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${var.api_gateway_execution_arn}/*/*"
}

output "function_name" {
  description = "Name of the Lambda function."

  value = aws_lambda_function.lambda_function.function_name
}


output "s3_bucket_key" {
  description = "Key for the archived file in S3."

  value = aws_s3_bucket_object.lambda_function.key
}

