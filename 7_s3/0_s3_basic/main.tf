# Create an S3 bucket
/*resource "aws_s3_bucket" "TF_S3_BUCKET" {
  bucket = "tf-example-bucket1234" # Replace with a globally unique name
  #acl    = "public-read"  # Deprecated

  tags = {
    Name = "TF_S3_BUCKET"
  }
}*/

# Define a bucket policy for public read access
# This Content-Disposition: inline header will instruct the browser to display the file rather than force it to download.
resource "aws_s3_object" "hello_txt" {
  #bucket = aws_s3_bucket.TF_S3_BUCKET.bucket
  bucket = var.bucket_name
  key    = "hello"
  source = "hello.txt"    # Replace with the local file path
  #acl    = "public-read" # Deprecated ["private", "public-read"] Default ACL for the object is "private"
  content_type = "text/plain"
  metadata = {
    "content-disposition" = "inline"
  }
}

/*# Block public access (bucket settings)
resource "aws_s3_bucket_public_access_block" "example" {
  #bucket = aws_s3_bucket.TF_S3_BUCKET.bucket
  bucket = var.bucket_name

  block_public_acls = false
  block_public_policy = false
  ignore_public_acls = false
  restrict_public_buckets = false
}*/

# Bucket policy to allow public read access to the entire bucket
resource "aws_s3_bucket_policy" "public_read_policy" {
  #bucket = aws_s3_bucket.TF_S3_BUCKET.bucket
  bucket = var.bucket_name
  policy = data.aws_iam_policy_document.public_read.json
  # depends_on = [aws_s3_bucket_public_access_block.example]  # Ensure this runs after the access block is configured
}

data "aws_iam_policy_document" "public_read" {
  statement {
    actions   = ["s3:GetObject"]
    #resources = ["arn:aws:s3:::${aws_s3_bucket.TF_S3_BUCKET.bucket}/*"]
    resources = ["arn:aws:s3:::${var.bucket_name}/*"]
    effect    = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

# Fetch the current region
data "aws_region" "current" {}

output "s3_file_url" {
  value = "https://${var.bucket_name}.s3.${data.aws_region.current.name}.amazonaws.com/${aws_s3_object.hello_txt.key}"
  description = "The public URL of the uploaded file"
}

