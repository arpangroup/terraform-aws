/*# Create S3 Bucket
resource "aws_s3_bucket" "TF_BUCKET_MY_WEBSITE" {
  bucket = "tf-bucket-website"

  tags = {
    Name = "TF_BUCKET_MY_WEBSITE"
  }
}

#Bucket Ownership
resource "aws_s3_bucket_ownership_controls" "TF_BUCKET_OWNERSHIP" {
  bucket = aws_s3_bucket.TF_BUCKET_MY_WEBSITE.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "TF_BUCKET_PUBLIC_ACCESS" {
  bucket =aws_s3_bucket.TF_BUCKET_MY_WEBSITE.id

  block_public_acls = false
  block_public_policy = false
  ignore_public_acls = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "TF_BUCKET_ACL" {
  bucket = aws_s3_bucket.TF_BUCKET_MY_WEBSITE
  acl = "public-read"
  depends_on = [
    aws_s3_bucket_ownership_controls.TF_BUCKET_OWNERSHIP,
    aws_s3_bucket_public_access_block.TF_BUCKET_PUBLIC_ACCESS
  ]
}



##################
resource "aws_s3_object" "TF_INDEX_HTML" {
  bucket = aws_s3_bucket.TF_BUCKET_MY_WEBSITE
  key    = "index.html"
  source = "index.html"
  acl = "public-read"
  content_type = "text/html"
}
resource "aws_s3_object" "TF_PROFILE" {
  bucket = aws_s3_bucket.TF_BUCKET_MY_WEBSITE
  key    = "profile.png"
  source = "profile.png"
  acl = "public-read"
  content_type = "text/html"
}

resource "aws_s3_bucket_website_configuration" "TF_BUCKET_WEBSITE_CONFIG" {
  bucket = aws_s3_bucket.TF_BUCKET_MY_WEBSITE

  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
  routing_rule {
    condition {
      key_prefix_equals = "api/"
    }
    redirect {
      replace_key_prefix_with = "api/v1/"
    }
  }
  depends_on = [aws_s3_bucket.TF_BUCKET_MY_WEBSITE]
}*/