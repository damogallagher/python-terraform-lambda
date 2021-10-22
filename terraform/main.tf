module "api-gateway" {
  source            = "./api-gateway"
  api_gateway_stage = var.api_gateway_stage
}
module "storage" {
  source              = "./storage"
  code_s3_bucket_name = var.code_s3_bucket_name
}

//Found an issue where the archive functionality would not work with depends_on
//When we try to push the artifact to s3 its not available
//Only way around this is to do the archiving in a module and use the module depends_on
module "archive_say_hello_lambda_func" {
  source        = "./archive"
  code_src_dir  = "app"
  code_src_file = "app/hello.py"
  zip_name      = "hello.zip"
}

module "say_hello_lambda_func" {
  source                      = "./compute"
  function_name               = "hello"
  zip_name                    = "hello.zip"
  src_code_bucket_id          = module.storage.src_code_bucket_id
  lambda_function_output_path = module.archive_say_hello_lambda_func.lambda_function_output_path
  lambda_function_base64      = module.archive_say_hello_lambda_func.lambda_function_base64
  lambda_runtime              = var.lambda_runtime
  lambda_handler              = "hello.handler"
  lambda_timeout              = var.lambda_timeout
  api_gateway_route_key       = "GET /hello"
  api_gateway_id              = module.api-gateway.api_gateway_id
  api_gateway_execution_arn   = module.api-gateway.api_gateway_execution_arn
  lambda_inline_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:ListAllMyBuckets"]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
  depends_on = [module.storage.src_code_bucket_id]
}
module "archive_s3_buckets_lambda_func" {
  source        = "./archive"
  code_src_dir  = "app"
  code_src_file = "app/s3-buckets.py"
  zip_name      = "s3-buckets.zip"
}
module "s3_buckets_lambda_func" {
  source                      = "./compute"
  function_name               = "s3-buckets"
  zip_name                    = "s3-buckets.zip"
  src_code_bucket_id          = module.storage.src_code_bucket_id
  lambda_function_output_path = module.archive_s3_buckets_lambda_func.lambda_function_output_path
  lambda_function_base64      = module.archive_s3_buckets_lambda_func.lambda_function_base64
  lambda_runtime              = var.lambda_runtime
  lambda_handler              = "s3-buckets.handler"
  lambda_timeout              = var.lambda_timeout
  api_gateway_route_key       = "GET /s3-buckets"
  api_gateway_id              = module.api-gateway.api_gateway_id
  api_gateway_execution_arn   = module.api-gateway.api_gateway_execution_arn
  lambda_inline_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListAllMyBuckets"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
  depends_on = [module.storage.src_code_bucket_id]
}

module "archive_list_cloudwatch_metrics_lambda_func" {
  source        = "./archive"
  code_src_dir  = "app"
  code_src_file = "app/list-cloudwatch-metrics.py"
  zip_name      = "list-cloudwatch-metrics.zip"
}
module "list_cloudwatch_metrics_lambda_func" {
  source                      = "./compute"
  function_name               = "list-cloudwatch-metrics"
  zip_name                    = "list-cloudwatch-metrics.zip"
  src_code_bucket_id          = module.storage.src_code_bucket_id
  lambda_function_output_path = module.archive_list_cloudwatch_metrics_lambda_func.lambda_function_output_path
  lambda_function_base64      = module.archive_list_cloudwatch_metrics_lambda_func.lambda_function_base64
  lambda_runtime              = var.lambda_runtime
  lambda_handler              = "list-cloudwatch-metrics.handler"
  lambda_timeout              = var.lambda_timeout
  api_gateway_route_key       = "GET /list-cloudwatch-metrics"
  api_gateway_id              = module.api-gateway.api_gateway_id
  api_gateway_execution_arn   = module.api-gateway.api_gateway_execution_arn
  lambda_inline_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "cloudwatch:ListMetrics"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
  depends_on = [module.storage.src_code_bucket_id]
}



module "archive_get_cloudwatch_metrics_data_lambda_func" {
  source        = "./archive"
  code_src_dir  = "app"
  code_src_file = "app/get-cloudwatch-metrics-data.py"
  zip_name      = "get-cloudwatch-metrics-data.zip"
}
module "get_cloudwatch_metrics_data_lambda_func" {
  source                      = "./compute"
  function_name               = "get-cloudwatch-metrics-data"
  zip_name                    = "get-cloudwatch-metrics-data.zip"
  src_code_bucket_id          = module.storage.src_code_bucket_id
  lambda_function_output_path = module.archive_get_cloudwatch_metrics_data_lambda_func.lambda_function_output_path
  lambda_function_base64      = module.archive_get_cloudwatch_metrics_data_lambda_func.lambda_function_base64
  lambda_runtime              = var.lambda_runtime
  lambda_handler              = "get-cloudwatch-metrics-data.handler"
  lambda_timeout              = var.lambda_timeout
  api_gateway_route_key       = "GET /get-cloudwatch-metrics-data"
  api_gateway_id              = module.api-gateway.api_gateway_id
  api_gateway_execution_arn   = module.api-gateway.api_gateway_execution_arn
  lambda_inline_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "cloudwatch:GetMetricData"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
  depends_on = [module.storage.src_code_bucket_id]
}