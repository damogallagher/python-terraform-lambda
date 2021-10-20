module "storage" {
  source              = "./storage"
  code_s3_bucket_name = var.code_s3_bucket_name
  //depends_on           = [module.storage.storage_bucket_name]
}
 
module "lambda_func" {
  source   = "./compute"
  code_src = "../../app"
  zip_name = "lambda.zip"
  src_code_bucket_id = module.storage.src_code_bucket_id
  lambda_runtime = var.lambda_runtime
  lambda_handler = var.lambda_handler
  depends_on           = [module.storage.src_code_bucket_id]
}