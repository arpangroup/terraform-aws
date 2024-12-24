# S3 Bucket Ownership Controls

## Key Features of S3 Bucket Ownership Controls
- **Enforces Object Ownership**: Ensures that only the bucket owner retains ownership of the objects in the bucket, even if they are uploaded by other AWS accounts.
- **Prevents ACLs from Overriding Ownership**: By enforcing the bucket owner's control over objects, it helps prevent issues where ACLs (Access Control Lists) might allow other accounts to control objects that should only be controlled by the bucket owner.
- **Works with S3 Block Public Access**: Combined with other settings, this provides a more secure, consistent mechanism for controlling access to your S3 resources.

## Use Cases:
1. **Prevent Other AWS Accounts from Controlling Your Objects**: If you're working in a cross-account environment where multiple AWS accounts upload objects to your bucket, this control ensures the bucket owner retains ownership of all objects.
2. **Block Public Access**: Enforcing ownership controls can be part of your overall strategy to block public access to your bucket, ensuring that only the authorized bucket owner can modify permissions.

## Example Usage in Terraform:
````hcl
resource "aws_s3_bucket" "example" {
  bucket = "my-example-bucket"
  acl    = "private"
}

resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.example.bucket

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
````
### Object Ownership Modes:
1. `BucketOwnerPreferred`: The bucket owner automatically owns objects uploaded by other AWS accounts (the default behavior). If objects are uploaded by the bucket owner, they retain ownership.
2. `ObjectWriter`: The uploader of the object (the "writer") retains ownership. This is the default if ownership controls are not configured.