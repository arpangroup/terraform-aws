# Create a VPC Flow Log
resource "aws_flow_log" "vpc_flow_log" {
  log_destination_type = "cloud-watch-logs" # ["s3", "cloud-watch-logs"]
  log_destination      = aws_cloudwatch_log_group.flow_log_group.arn # aws_s3_bucket.flow_log_bucket.arn
  traffic_type         = "ALL" # Capture all traffic (ACCEPT, REJECT)
  vpc_id               = var.vpc.id
  iam_role_arn         = aws_iam_role.vpc_flow_log_role.arn

  tags = {
    Name = "VPC Flow Log"
  }
}

# Create a CloudWatch Log Group for storing VPC Flow Logs
resource "aws_cloudwatch_log_group" "flow_log_group" {
  name = "tf-vpc-flow-logs"

  tags = {
    Name = "TF-VPC Flow Log Group"
  }
}


# Create an IAM Role for VPC Flow Logs
resource "aws_iam_role" "vpc_flow_log_role" {
  name = "vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach a policy to the IAM role to allow writing logs to CloudWatch
resource "aws_iam_role_policy" "vpc_flow_log_policy" {
  name   = "vpc-flow-logs-policy"
  role   = aws_iam_role.vpc_flow_log_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "logs:CreateLogStream",
        Resource = "${aws_cloudwatch_log_group.flow_log_group.arn}"
      },
      {
        Effect   = "Allow",
        Action   = "logs:PutLogEvents",
        Resource = "${aws_cloudwatch_log_group.flow_log_group.arn}:*"
      }
    ]
  })
}

# Optional: If you want to put the log to S3
# Attach a policy to the S3 bucket to allow VPC Flow Logs to write logs
/*resource "aws_s3_bucket_policy" "flow_log_bucket_policy" {
  #bucket = aws_s3_bucket.flow_log_bucket.id
  bucket = var.s3.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowVPCFlowLogDelivery",
        Effect    = "Allow",
        Principal = { Service = "delivery.logs.amazonaws.com" },
        Action    = "s3:PutObject",
        #Resource  = "${aws_s3_bucket.flow_log_bucket.arn}/*",
        Resource  = "${var.s3.arn}/*",
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}*/

provider "aws" {
  region = "us-east-1"
}
