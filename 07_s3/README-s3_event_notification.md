
## Triggering AWS Services with S3 Bucket Notifications
You can configure S3 to send notifications to multiple destinations (e.g., Lambda, SQS, SNS) simultaneously.
````hcl
resource "aws_s3_bucket_notification" "s3_multiple_triggers" {
  bucket = aws_s3_bucket.my_bucket.id

  # S3 --> LambdaFunction
  lambda_function {
    lambda_function_arn  = "arn:aws:lambda:us-east-1:123456789012:function:example_lambda" # S3 to trigger notifications in another AWS account by specifying the ARN
    #lambda_function_arn = aws_lambda_function.example_lambda.arn
    events               = ["s3:ObjectCreated:*"]

    filter_prefix = "images/"  # Trigger only for objects in the "images/" prefix
    filter_suffix = ".jpg"     # Trigger only for .jpg files
  }

  # configure an S3 bucket to send event notifications to an SQS queue.
  queue {
    queue_arn = aws_sqs_queue.example_queue.arn
    events    = ["s3:ObjectCreated:*"]
    filter_suffix = ".log"  # Optional: Trigger only for .log files
  }

  # configure an S3 bucket to publish event notifications to an SNS topic.
  topic {
    topic_arn = aws_sns_topic.example_topic.arn
    events    = ["s3:ObjectCreated:*"]
    filter_suffix = ".csv"
  }
}
````

---
## Amazon EventBridge (via S3 EventBridge integration)
S3 can send events to Amazon EventBridge, which can then trigger a wide range of AWS services or custom workflows.
- S3 can send notifications directly to EventBridge without explicitly creating a bucket notification resource.
- To set this up, enable EventBridge notifications on your bucket:
````hcl
resource "aws_s3_bucket" "example" {
  bucket = "my-example-bucket"

  versioning {
    enabled = true
  }

  eventbridge {
    enabled = true
  }
}
````