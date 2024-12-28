# [S3 Object Ownership](https://docs.aws.amazon.com/AmazonS3/latest/userguide/about-object-ownership.html):
S3 Object Ownership is an Amazon S3 bucket-level setting that you can use to control ownership of objects uploaded to your bucket and to disable or enable [access control lists (ACLs)](https://docs.aws.amazon.com/AmazonS3/latest/userguide/acl-overview.html).

**By default, Object Ownership is set to the Bucket owner enforced setting and all ACLs are disabled**.

- **ACLs disabled (recommended)**: All objects in this bucket are owned by this account. Access to this bucket and its objects is specified using only policies.
- **ACLs enabled**: Objects in this bucket can be owned by other AWS accounts. Access to this bucket and its objects can be specified using ACLs.
    - **Bucket owner preferred**: If new objects written to this bucket specify the bucket-owner-full-control canned ACL, they are owned by the bucket owner. Otherwise, they are owned by the object writer.
        - **Object writer**: The object writer remains the object owner.
        - **BucketOwnerEnforced**: The bucket owner is always the object owner, and ACLs are disabled.

- ### Configure Object Ownership
  To set ownership to `BucketOwnerEnforced` and disable ACLs:
  ````hcl
  resource "aws_s3_bucket_ownership_controls" "example" {
    bucket = aws_s3_bucket.example.id
  
    rule {
      object_ownership = "BucketOwnerEnforced"
    }
  }
  ````
- ### Optional: Configure S3 Bucket ACL
  If you use `BucketOwnerEnforced`, ACLs like `bucket-owner-full-control` or `public-read` are ignored, as ACLs are disabled. For other ownership modes, you can set ACLs:
  ````hcl
  resource "aws_s3_bucket_acl" "example" {
    bucket = aws_s3_bucket.example.id
    acl    = "private"
  }
  ````

- ### Complete Example
    Below is a complete example to configure a bucket with `BucketOwnerEnforced`:
    ````hcl
    provider "aws" {
      region = "us-east-1"
    }
    
    resource "aws_s3_bucket" "example" {
      bucket = "example-bucket"
    }
    
    resource "aws_s3_bucket_ownership_controls" "example" {
      bucket = aws_s3_bucket.example.id
    
      rule {
        object_ownership = "BucketOwnerEnforced"
      }
    }
    ````