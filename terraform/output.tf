output "lambda_bucket_id" {
  description = "Id of the S3 bucket used to store function code."
  value       = module.storage.src_code_bucket_id
}

output "lambdafunc_function_name" {
  description = "Name of the Lambda function."

  value = module.lambda_func.function_name
}

output "lambdafunc_base_url" {
  description = "Base URL for API Gateway stage."

  value = module.lambda_func.base_url
}