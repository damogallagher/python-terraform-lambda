variable "code_src_dir" {
  type = string
}
variable "zip_name" {
  type = string
}

data "archive_file" "lambda_function" {
  type = "zip"

  source_dir  = "${path.module}/../../${var.code_src_dir}"
  output_path = "${path.module}/${var.zip_name}"
}

output "lambda_function_output_path" {
  description = "The output path for the function"
  value = data.archive_file.lambda_function.output_path
}
output "lambda_function_base64" {
  description = "The base64sha256 for the function"
  value = data.archive_file.lambda_function.output_base64sha256
}
