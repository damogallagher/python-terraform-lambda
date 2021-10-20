variable "code_src_dir" {
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

data "archive_file" "minimal_lambda_function" {
  type = "zip"

  source_dir  = "${path.module}/../../${var.code_src_dir}"
  output_path = "${path.module}/${var.zip_name}"
}

resource "aws_s3_bucket_object" "minimal_lambda_function" {
  bucket = "${var.src_code_bucket_id}"

  key    = "${var.zip_name}"
  source = data.archive_file.minimal_lambda_function.output_path

  etag = filemd5(data.archive_file.minimal_lambda_function.output_path)
  depends_on  = [data.archive_file.minimal_lambda_function]
}


resource "aws_lambda_function" "minimal_lambda_function" {
  function_name = "MinimalLambdaFunction"

  s3_bucket = "${var.src_code_bucket_id}"
  s3_key    = aws_s3_bucket_object.minimal_lambda_function.key

  runtime = "${var.lambda_runtime}"
  handler = "${var.lambda_handler}"

  source_code_hash = data.archive_file.minimal_lambda_function.output_base64sha256

  role = aws_iam_role.lambda_exec.arn
  depends_on           = [data.archive_file.minimal_lambda_function]
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


resource "aws_apigatewayv2_api" "lambda" {
  name          = "serverless_lambda_api_gateway"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "lambda" {
  api_id = aws_apigatewayv2_api.lambda.id

  name        = "dev"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_apigatewayv2_integration" "minimal_lambda_function" {
  api_id = aws_apigatewayv2_api.lambda.id

  integration_uri    = aws_lambda_function.minimal_lambda_function.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "minimal_lambda_function" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "GET /hello"
  target    = "integrations/${aws_apigatewayv2_integration.minimal_lambda_function.id}"
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.lambda.name}"

  retention_in_days = 30
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.minimal_lambda_function.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}

output "function_name" {
  description = "Name of the Lambda function."

  value = aws_lambda_function.minimal_lambda_function.function_name
}

output "base_url" {
  description = "Base URL for API Gateway stage."

  value = aws_apigatewayv2_stage.lambda.invoke_url
}

output "s3_bucket_key" {
  description = "Key for the archived file in S3."

  value = aws_s3_bucket_object.minimal_lambda_function.key
}

output "archive_hash" {
  description = "Hash of the archive."

  value = data.archive_file.minimal_lambda_function.output_base64sha256
}