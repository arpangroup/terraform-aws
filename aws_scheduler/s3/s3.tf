provider "aws" {
  region = "us-east-1"
}
variable "bucket_name" {
  default = "tf-example-bucket123"
}
# Fetch the current region
data "aws_region" "current" {}


# Upload The file/Object
resource "aws_s3_object" "emp_data" {
  #bucket = aws_s3_bucket.TF_S3_BUCKET.bucket
  bucket = var.bucket_name
  key    = "emp_data"
  source = "emp_data.csv"
  content_type = "text/csv" # "text/plain"
  metadata = {
    "content-disposition" = "inline"
  }
}

output "s3_file_url" {
  value = "https://${var.bucket_name}.s3.${data.aws_region.current.name}.amazonaws.com/${aws_s3_object.emp_data.key}"
  description = "The public URL of the uploaded file"
}












