
# CloudWatch Custom Metrics with Terraform and Lambda Automation

This guide walks you through the process of creating a CloudWatch custom metric using Terraform and automating it with an AWS Lambda function. The entire process is captured in a single `README.md` file for ease of use.

## Prerequisites
Before starting, ensure you have the following prerequisites:

- Terraform installed (version 1.0 or later).
- AWS CLI configured with appropriate access to your AWS account.
- AWS Lambda permissions for creating and updating Lambda functions.
- AWS IAM permissions to create CloudWatch Metrics and other necessary AWS resources.

## Steps to Create CloudWatch Custom Metrics using Terraform and Automate with Lambda

### Step 1: Create the Terraform Configuration

1. **Create a Terraform file (`main.tf`)**:

   The following Terraform script will create a Lambda function that publishes a custom metric to AWS CloudWatch.

    ```hcl
    # ec2.tf

    provider "aws" {
      region = "us-east-1"
    }

    resource "aws_lambda_function" "cloudwatch_metric_publisher" {
      function_name = "CloudWatchMetricPublisher"

      runtime = "python3.8"
      role    = aws_iam_role.lambda_role.arn
      handler = "lambda_function.lambda_handler"

      # Lambda function code
      filename = "lambda_function.zip"

      source_code_hash = filebase64sha256("lambda_function.zip")
    }

    resource "aws_iam_role" "lambda_role" {
      name = "lambda_execution_role"

      assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action    = "sts:AssumeRole"
            Effect    = "Allow"
            Principal = {
              Service = "lambda.amazonaws.com"
            }
          }
        ]
      })
    }

    resource "aws_iam_policy" "cloudwatch_policy" {
      name        = "CloudWatchPolicy"
      description = "Policy to allow Lambda to publish to CloudWatch Metrics"

      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action   = "cloudwatch:PutMetricData"
            Effect   = "Allow"
            Resource = "*"
          }
        ]
      })
    }

    resource "aws_iam_role_policy_attachment" "lambda_cloudwatch_policy" {
      role       = aws_iam_role.lambda_role.name
      policy_arn = aws_iam_policy.cloudwatch_policy.arn
    }
    ```

2. **Create the Lambda Function Code (`lambda_function.py`)**:

   Below is the Python Lambda function code that publishes custom metrics to CloudWatch.

    ```python
    # lambda_retry_sync.py

    import boto3
    import time

    def lambda_handler(event, context):
        cloudwatch = boto3.client('cloudwatch')

        # Publish a custom metric to CloudWatch
        cloudwatch.put_metric_data(
            Namespace='MyCustomNamespace',
            MetricName='MyCustomMetric',
            Value=1,
            Unit='Count',
            Timestamp=int(time.time())
        )

        return {
            'statusCode': 200,
            'body': 'Metric published successfully'
        }
    ```

### Step 2: Deploy the Terraform Configuration

1. **Initialize Terraform**:
   Run the following command to initialize your Terraform configuration:

   ```bash
   terraform init
   ```

2. **Apply the Terraform Configuration**:
   Apply the configuration to create the Lambda function and IAM role:

   ```bash
   terraform apply
   ```

3. **Confirm the Deployment**:
   Terraform will ask for confirmation. Type `yes` to confirm the deployment.

### Step 3: Zip the Lambda Function Code

1. Zip the Lambda function code into a deployment package:

   ```bash
   zip lambda_function.zip lambda_retry_sync.py
   ```

### Step 4: Set Up Lambda Function Execution

1. **Create Lambda Execution Role**:
   Ensure that the Lambda function has permission to publish metrics to CloudWatch. This is handled by the IAM role and policy created earlier in the Terraform configuration.

### Step 5: Test the Lambda Function

You can test the Lambda function by manually invoking it via the AWS Lambda Console or using the AWS CLI:

```bash
aws lambda invoke --function-name CloudWatchMetricPublisher output.txt
```

This will invoke the Lambda function and send a custom metric to CloudWatch. You should see the metric appear in the CloudWatch Console under the custom namespace `MyCustomNamespace`.

### Step 6: Automate Lambda Invocation

To automate the invocation of the Lambda function, you can set up an AWS CloudWatch Event Rule to trigger the Lambda function on a schedule (e.g., every 5 minutes).

1. **Create a CloudWatch Event Rule**:

   Use the following Terraform code to set up a scheduled rule:

    ```hcl
    resource "aws_cloudwatch_event_rule" "lambda_schedule" {
      name                = "lambda-schedule"
      schedule_expression = "rate(5 minutes)"
    }

    resource "aws_cloudwatch_event_target" "lambda_target" {
      rule      = aws_cloudwatch_event_rule.lambda_schedule.name
      target_id = "LambdaFunction"
      arn       = aws_lambda_function.cloudwatch_metric_publisher.arn
    }

    resource "aws_lambda_permission" "allow_cloudwatch" {
      statement_id  = "AllowCloudWatchInvoke"
      action        = "lambda:InvokeFunction"
      principal     = "events.amazonaws.com"
      function_name = aws_lambda_function.cloudwatch_metric_publisher.function_name
    }
    ```

2. **Apply the CloudWatch Event Rule**:
   Add the new resources to your Terraform configuration and run:

   ```bash
   terraform apply
   ```

This sets up the Lambda function to run every 5 minutes, publishing the custom metric to CloudWatch on a regular schedule.

### Step 7: Monitor Your Custom Metric

1. Go to the **CloudWatch Console** and navigate to **Metrics**.
2. Select the **Custom Namespaces** and find `MyCustomNamespace`.
3. You should see `MyCustomMetric` listed under the metrics, with data points showing up every 5 minutes.

---

## Conclusion

You have successfully created a custom CloudWatch metric using Terraform and automated the process with an AWS Lambda function. You can extend this setup to publish multiple metrics, customize the Lambda logic, or trigger the Lambda function based on specific events.

