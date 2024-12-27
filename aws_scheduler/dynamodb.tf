resource "aws_dynamodb_table" "results_table" {
  name           = "results-table"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}
