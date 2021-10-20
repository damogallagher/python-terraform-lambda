variable "code_src" {
  type = string
}
variable "zip_name" {
  type = string
}

data "archive_file" "minimal_lambda_function" {
  type = "zip"

  source_dir  = "${path.module}/../../../${var.code_src}"
  output_path = "${path.module}/${var.zip_name}"
}

output "archive_output_path" {
  description = "Output path for the archive."

  value = data.archive_file.minimal_lambda_function.output_path
}
output "archive_hash" {
  description = "Hash of the archive."

  value = data.archive_file.minimal_lambda_function.output_base64sha256
}
