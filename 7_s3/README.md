## AWS S3 : Global Service
- S3 Availability (`11 9's`)
- [Object Ownership](README-s3_object_ownership.md) (`ACL disabled` / `ACL enabled`)
- [Bucket Ownership Controls](README-s3_bucket_ownership_controls.md) (`Block all public access`)
- **[S3 Bucket Policy](README-s3_bucket_policy.md)**
- Bucket Versioning
- S3 Tagging
- Default Encryption
- Object Locking
- [S3 Storage Classes](README-s3_storage_classes.md)
- [S3 Storage Calculator](README-s3_storage_calculator.md)
- [Transfer acceleration](README-s3_transfer_acceleration.md)
- **Event notifications** (Send notification when specific event occur on your bucket)
- Requester Pays
- Static Website Hosting
- Permission Policies
- Secure Bucket
- CloudFront Distribution
- S3 DNS Route53


## Videos:
- [AWS S3 Full Course | From Beginner to Expert | Deploy Real-Time Projects on AWS - Part 22](https://www.youtube.com/watch?v=A2N9OIun9dU&list=PL7iMyoQPMtAPVSnMZOpptxGoPqwK1piC6&index=22)
- [Zero to Hero: AWS S3 + Terraform Full Guide! - Part 23](https://www.youtube.com/watch?v=v_7Vzh4oGhk&list=PL7iMyoQPMtAPVSnMZOpptxGoPqwK1piC6&index=23)


## Create an S3 Bucket
````hcl
resource "aws_s3_bucket" "TF_S3_BUCKET" {
  bucket = "my-example-bucket"
  acl    = "private"
}
````

### Additional Configuration Options
- ### Versioning
    ````hcl
    resource "aws_s3_bucket_versioning" "example" {
      bucket = aws_s3_bucket.example.id
      versioning_configuration {
        status = "Enabled"
      }
    }
    ````
    To list all versions of an object:
    ````bash
    aws s3api list-object-versions --bucket your-bucket-name
    ````
    To delete a specific version of an object:
    ````bash
    aws s3api delete-object --bucket your-bucket-name --key your-object-key --version-id version-id
    ````
  
- ### Server-Side Encryption:
    ````hcl
    resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
      bucket = aws_s3_bucket.example.id
      rule {
        apply_server_side_encryption_by_default {
          sse_algorithm = "AES256"
        }
      }
    }
    ````
- ### Bucket Policies:
  ````hcl
  resource "aws_s3_bucket_policy" "example" {
    bucket = aws_s3_bucket.example.id
    policy = <<EOT
          {
            "Version": "2012-10-17",
            "Statement": [
              {
                # Allow Public Read Access to All Objects:
                "Action": "s3:GetObject",
                "Effect": "Allow",
                "Resource": "arn:aws:s3:::my-example-bucket/*",
                "Principal": "*"
              },
              {
                # Restrict Access to a Specific IP Range:
                "Effect": "Deny",
                "Principal": "*",
                "Action": "s3:*",
                "Resource": "arn:aws:s3:::my-bucket-name/*",
                "Condition": {
                  "NotIpAddress": {
                    "aws:SourceIp": "203.0.113.0/24"
                  }
                }
              }
            ]
          }
          EOT
  }
  ````

- ### Grant Cross-Account Access:
    ````
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "AWS": "arn:aws:iam::123456789012:root"
          },
          "Action": "s3:ListBucket",
          "Resource": "arn:aws:s3:::my-bucket-name"
        },
        {
          "Effect": "Allow",
          "Principal": {
            "AWS": "arn:aws:iam::123456789012:root"
          },
          "Action": "s3:GetObject",
          "Resource": "arn:aws:s3:::my-bucket-name/*"
        }
      ]
    }
    ````


- ### Lifecycle Rules:
    ````hcl
    resource "aws_s3_bucket_lifecycle_configuration" "example" {
      bucket = aws_s3_bucket.example.id
      rule {
        id = "expire-old-objects"
        status = "Enabled"
        expiration {
          days = 30
        }
      }
    }
    ````

## Why there is separate AWS S3 bucket policies?
The separation of **AWS S3 bucket policies** from other access control mechanisms (such as IAM policies or ACLs) exists to provide **fine-grained control** and flexibility specific to managing **S3 bucket resources**. Here's why a separate mechanism for bucket policies is beneficial:
1. **Resource-Level Granularity**: **Bucket Policies** apply directly to **a specific bucket and its contents**.
2. **Static Website Hosting**: Grant public read access to objects for website access.
3. **Data Sharing**: Enable **cross-account access** to specific resources.
4. **Security Controls**: Restrict access based on conditions like IP address, time, or user attributes.
- ### Shared Responsibility for Access Control:
  - **IAM Policies:**
    - Define what a specific user, role, or group can do across all AWS resources.
    - Used by administrators to control internal users' permissions.
  - **Bucket Policies:**
    - Define what actions are allowed or denied for all users (including external users) on a specific bucket.
    - Used to manage access for external entities (e.g., third-party accounts, applications).
- ### Legacy Support and ACL Replacement
- Amazon S3 started with **Access Control Lists** (**ACLs**) for resource permissions. Over time, bucket policies were introduced as a more powerful and flexible alternative.
- ACLs are now considered legacy, and bucket policies are recommended for more robust access management.

### Comparison: IAM Policy vs. Bucket Policy
| **Feature**             | **IAM Policy**                               | **S3 Bucket Policy**                          |
|-------------------------|---------------------------------------------|---------------------------------------------|
| **Scope**               | Applies to users, roles, or groups          | Applies to specific S3 buckets and objects  |
| **Cross-Account Access**| Limited; requires role assumption           | Supports directly with `Principal`          |
| **Conditions**          | Limited to generic AWS conditions           | Supports S3-specific conditions (e.g., IP)  |
| **Public Access**       | Not applicable                              | Allows anonymous (public) access           |
| **Management**          | Centralized for all AWS services            | Decentralized, bucket-specific              |

## When to Use S3 Bucket Policies
- To grant **cross-account access** to an S3 bucket.
-  To make a bucket or objects **publicly accessible** (e.g., for a website).
-  To enforce **specific conditions** on bucket access.
-  When delegating control to teams responsible for managing specific buckets.
