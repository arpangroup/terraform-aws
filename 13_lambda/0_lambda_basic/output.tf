# Fetch the current region
data "aws_region" "current" {}



/*output "function_details" {
  value = aws_lambda_function.TF_LAMBDA_EXAMPLE
}*/

output "lambda_curl" {
  value = <<-EOT
    ..............................................
    curl -X POST https://${aws_lambda_function_url.my_lambda_url.url_id}.lambda-url.${data.aws_region.current.name}.on.aws \
      -H "Content-Type: application/json" \
      -d '{"key1": "value1", "key2": "value2"}'
    ..............................................
  EOT
}