module "api-gateway" {
  source              = "./api-gateway"
  api_gateway_stage   = var.api_gateway_stage
}
module "storage" {
  source              = "./storage"
  code_s3_bucket_name = var.code_s3_bucket_name
}

//Found an issue where the archive functionality would not work with depends_on
//When we try to push the artifact to s3 its not available
//Only way around this is to do the archiving in a module and use the module depends_on
module "archive_lambda_func_1" {
  source       = "./archive"
  code_src_dir = "app"
  zip_name     = "lambda222.zip"
}

module "lambda_func_1" {
  source                      = "./compute"
  function_name               = "list-all-buckets"
  zip_name                    = "lambda222.zip"
  src_code_bucket_id          = module.storage.src_code_bucket_id
  lambda_function_output_path = module.archive_lambda_func_1.lambda_function_output_path
  lambda_function_base64      = module.archive_lambda_func_1.lambda_function_base64
  lambda_runtime              = var.lambda_runtime
  lambda_handler              = var.lambda_handler
  api_gateway_route_key       = "GET /hello"
  api-gateway-id              = module.api-gateway.api-gateway-id
  api-gateway-execution-arn   = module.api-gateway.api-gateway-execution-arn
  depends_on                  = [module.storage.src_code_bucket_id]
}
module "archive_lambda_func_2" {
  source       = "./archive"
  code_src_dir = "app"
  zip_name     = "lambda333.zip"
}
module "lambda_func_2" {
  source                      = "./compute"
  function_name               = "list-me-buckets"
  zip_name                    = "lambda333.zip"
  src_code_bucket_id          = module.storage.src_code_bucket_id
  lambda_function_output_path = module.archive_lambda_func_2.lambda_function_output_path
  lambda_function_base64      = module.archive_lambda_func_2.lambda_function_base64
  lambda_runtime              = var.lambda_runtime
  lambda_handler              = var.lambda_handler
  api_gateway_route_key       = "GET /hello-2"
  api-gateway-id              = module.api-gateway.api-gateway-id
  api-gateway-execution-arn   = module.api-gateway.api-gateway-execution-arn
  depends_on                  = [module.storage.src_code_bucket_id]
}