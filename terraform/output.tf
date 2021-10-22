output "lambda_bucket_id" {
  description = "Id of the S3 bucket used to store function code."
  value       = module.storage.src_code_bucket_id
}

output "APIGateway_base_url" {
  description = "Base URL for API Gateway stage."

  value = module.api-gateway.base_url
}