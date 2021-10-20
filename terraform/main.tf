module "storage" {
  source              = "./storage"
  code_s3_bucket_name = var.code_s3_bucket_name
  //depends_on           = [module.storage.storage_bucket_name]
}

//Found an issue where the archive functionality would not work with depends_on
//When we try to push the artifact to s3 its not available
//Only way around this is to do the archiving in a module and use the module depends_on
module "archive_lambda_func" {
  source       = "./archive"
  code_src_dir = "app"
  zip_name     = "lambda222.zip"
}

module "lambda_func" {
  source                      = "./compute"
  zip_name                    = "lambda222.zip"
  src_code_bucket_id          = module.storage.src_code_bucket_id
  lambda_function_output_path = module.archive_lambda_func.lambda_function_output_path
  lambda_function_base64      = module.archive_lambda_func.lambda_function_base64
  lambda_runtime              = var.lambda_runtime
  lambda_handler              = var.lambda_handler
  depends_on                  = [module.storage.src_code_bucket_id]
}