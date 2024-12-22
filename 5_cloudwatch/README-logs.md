# AWS CloudWatch Logs
- Log Group
- Log Stream
- LogInsights


## Create a LogGroup & LogStream
````hcl
resource "aws_cloudwatch_log_group" "TF_LOG_GROUP" {
  name              = "/tf-example/log-group"
  retention_in_days = 1 # Retain logs for 1 days
}

resource "aws_cloudwatch_log_stream" "example" {
  name           = "tf-example-log-stream"
  log_group_name = aws_cloudwatch_log_group.TF_LOG_GROUP.name
}
````

## Show all log groups
````bash
aws logs describe-log-groups --query "logGroups[*].logGroupName" --output table
OR
aws logs describe-log-groups
````
- `aws logs describe-log-groups`: Retrieves information about your log groups.
- `--query "logGroups[*].logGroupName"`: Filters the output to display only the names of the log groups.
- `--output table`: Formats the output in a table for better readability. You can also use `json` or `text` formats as needed.



## What is Instance Profile?
An instance profile is a container for an IAM role that enables EC2 instances to assume that role and access AWS resources.
### Purpose of an Instance Profile
An instance profile allows an EC2 instance to securely access AWS services (e.g., S3, CloudWatch) without hardcoding AWS credentials in the instance.
### Role vs. Instance Profile:
- A role specifies permissions and policies.
- An **instance profile** acts as a bridge that lets EC2 instances assume a role.
- Each EC2 instance can be associated with one instance profile.
- An instance profile must contain exactly one IAM role.