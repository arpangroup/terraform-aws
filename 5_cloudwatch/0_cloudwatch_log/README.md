# Configure EC2 instance logs to be sent to CloudWatch
To configure EC2 instance logs to be sent to CloudWatch, follow these steps:<br/>
- [Setup Cloud Watch using Terraform](README-setup_ClouudWatch_using_terraform.md)
- [AmazonCloudWatch Documentation](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/install-CloudWatch-Agent-commandline-fleet.html)
- [Download Word Document - CloudWatch-AWS CLI](../../diagrams/CloudWatch.pdf)

## Step1. Set up IAM Role for the EC2 Instance
To enable the CloudWatch agent to send data from the instance, you must attach an IAM role to the instance. The role to attach is `CloudWatchAgentServerRole`. You should have created this role previously.
1. Go to the IAM Management Console: Roles > Create role.
2. Select AWS service and choose EC2.
3. Attach the **CloudWatchAgentServerPolicy** managed policy
4. Name the role (e.g., `EC2CloudWatchLoggingRole`) and create it.
5. Attach the IAM role to your EC2 instance:
    - Go to the **EC2 Management Console** > Select your instance > **Actions** > **Security** > **Modify IAM role**.

## Step2: Install the CloudWatch Agent on the EC2 Instance
Connect to your EC2 instance via SSH. & install the CloudWatch agent:
````bash
sudo yum install amazon-cloudwatch-agent -y  # Amazon Linux
sudo apt-get install amazon-cloudwatch-agent -y  # Ubuntu
````
Alternatively, download the agent:
````bash
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
sudo rpm -U ./amazon-cloudwatch-agent.rpm

````

## Step3: Configure the CloudWatch Agent
````console
sudo nano /opt/aws/amazon-cloudwatch-agent/bin/config.json

{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/home/ec2-user/api.log",
            "log_group_name": "MyApplicationLogs",
            "log_stream_name": "{instance_id}-api-log",
            "timestamp_format": "%Y-%m-%dT%H:%M:%S.%fZ",
            "timezone": "UTC"
          }
        ]
      }
    }
  }
}
````
Save the file in `/opt/aws/amazon-cloudwatch-agent/bin/config.json`.

## Step4: Start and Verify the CloudWatch Agent
1. Start the agent:
    ````bash
    sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
      -a start -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s
    ````
   - `-a` **(action)**: 
     - `fetch-config`: Fetch configuration.
     - `start`: Start the agent.
     - `stop`: Stop the agent.
     - `status`: Check agent status.
     - `restart`: Restart the agent.
     - `test`: Test the configuration.
     - `metrics`: Check metrics collection.
   - `-m` **(mode)**: This specifies the mode in which the agent is running.
     - `ec2`: EC2 instance (default mode for AWS EC2).
     - `ssm`: EC2 instance managed via AWS Systems Manager (SSM).
     - `onPrem`: On-premises machine (non-AWS machine).
     - `docker`: CloudWatch agent running in a Docker container.
     - `local`: Local machine or VM outside of AWS/EC2.
   - `-c` **(configuration file)**: This specifies the path to the configuration file. In your example, file:configuration_file_path indicates that the configuration file is located at the specified path on the local system.
   - `-s` **(start)**: This flag is used to start the CloudWatch agent after the configuration is fetched or applied. It ensures that the agent begins running immediately after the configuration is applied.
2. Verify that the agent is running:
    ````bash
   sudo systemctl status amazon-cloudwatch-agent
   ````
3. Check logs to ensure data is sent:
    ````bash
   tail -f /opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log
   ````

4. Verify CloudWatch Metrics or Logs: Fetch the CloudWatch Agent status using the CLI:
    ````bash
    /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a status
    ````
    output:
    ````json
    {
      "status": "running",
      "configstatus": "configured",
      "cwoc_status": "stopped"
    }
    ````


> NOTE: Logs are automatically sent to specified `log groups` (`ec2-system-logs` and `ec2-cloud-init-logs`).



## Step5: Verify Logs in CloudWatch
1. Go to the **CloudWatch Management Console**.
2. Navigate to **Log Groups** and confirm your logs (e.g., `EC2InstanceLogs`) are being received.
3. Check the log streams (e.g., based on `instance_id`).



## Step6: Integrate Application Log like SpringBoot
To integrate your application logs (stored in `/home/ec2-user/api.log`) with CloudWatch, follow these steps:

### Step6.1: Create a CloudWatch Log Group
Create a log group in CloudWatch where your logs will be stored.
````bash
aws logs create-log-group --log-group-name /my-springboot-app-logs
````
[Create Log Group and Log StreamTerraform](3_log_group.tf)


### Step6.2: Install the CloudWatch Agent
Install the CloudWatch Agent on your EC2 instance.
````bash
sudo yum update -y
sudo yum install -y amazon-cloudwatch-agent
````
[Install CloudWatch Agent with AWS UsedData using Terraform](2_ec2.tf)

### Step6.3: Update the CloudWatch Agent Configuration
Open or create the CloudWatch agent configuration file:
````console
sudo nano /opt/aws/amazon-cloudwatch-agent/bin/config.json

{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/home/ec2-user/api.log",
            "log_group_name": "spring-app-logs",
            "log_stream_name": "{instance_id}-api-log",
            "timestamp_format": "%Y-%m-%dT%H:%M:%S.%fZ",
            "timezone": "UTC"
          }
        ]
      }
    }
  }
}
````
Full configs:
````json
{
  "agent": {
    "run_as_user": "root"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/messages",
            "log_group_name": "ec2-system-logs",
            "log_stream_name": "{instance_id}/messages",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/cloud-init.log",
            "log_group_name": "ec2-cloud-init-logs",
            "log_stream_name": "{instance_id}/cloud-init.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/api.log",
            "log_group_name": "spring-app-logs",
            "log_stream_name": "{instance_id}-api-log",
            "timestamp_format": "%Y-%m-%dT%H:%M:%S.%fZ",
            "timezone": "UTC"
          }
        ]
      }
    }
  }
}
````

### Step6.4: Update Spring Boot Logging Configuration
Configure Spring Boot to write logs to a specific file, e.g., `/var/log/api.log`.
````properties
logging.file.name=/var/log/api.log
logging.level.root=INFO
````
This ensures Spring Boot logs are written to /var/log/api.log.


### Step6.5: Start or Restart the CloudWatch Agent
Apply the updated configuration:
````bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
    -s 
````
If the agent is already running, restart it:
````bash
sudo systemctl restart amazon-cloudwatch-agent
````

### Step6.6: Verify Log Upload
Check the CloudWatch Agent logs for issues:
````bash
tail -f /opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log
````

## Step6.7:. Verify Logs in CloudWatch
Once the CloudWatch Agent is running, logs from `/var/log/api.log` should start appearing in the CloudWatch log group `/spring-app-logs`.

Go to the CloudWatch Management Console:
- Navigate to **Log Groups** > **MyApplicationLogs**.
- Confirm logs from `/var/log/api.log` are appearing in the log stream.

# Optional: Set Up Log Rotation (Optional)
To avoid large log files filling up disk space:
1. Install logrotate if not already installed:
   ````bash
   sudo yum install logrotate -y
   ````
2. Configure log rotation for `api.log`:
   ````text
   /home/ec2-user/api.log {
      daily
      rotate 7
      compress
      missingok
      notifempty
      copytruncate
   }
   ````
3. Test the configuration:
   ````bash
   sudo logrotate -f /etc/logrotate.d/api-log
   ````

# Optional: Create LogGroup using Terraform
````hcl
# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "TF_LOG_GROUP" {
  name              = "spring-app-logs"
  retention_in_days = 7 # how long log data is retained in the group before being automatically deleted.
}

# CloudWatch Log Stream: Sequential sets of log events from a single resource.
# EX: Logs from an EC2 instance or a Lambda function.
resource "aws_cloudwatch_log_stream" "TF_CLOUDWATCH_LOG_STREAM" {
  name           = "${aws_instance.TF_WEB_APP.id}-api-log"  # Dynamically set based on instance ID
  log_group_name = aws_cloudwatch_log_group.TF_LOG_GROUP.name
}
````


# S3 CloudWatch Agent Configuration File
````hcl
# Provide CloudWatch Agent Configuration File
resource "aws_s3_bucket" "agent_config" {
  bucket = "cloudwatch-agent-config"
}

resource "aws_s3_bucket_object" "agent_config_file" {
  bucket = aws_s3_bucket.agent_config.bucket
  key    = "amazon-cloudwatch-agent.json"
  content = <<-EOF
    {
      "agent": {
        "run_as_user": "root"
      },
      "logs": {
        "logs_collected": {
          "files": {
            "collect_list": [
              {
                "file_path": "/var/log/messages",
                "log_group_name": "ec2-system-logs",
                "log_stream_name": "{instance_id}/messages",
                "timezone": "UTC"
              },
              {
                "file_path": "/var/log/cloud-init.log",
                "log_group_name": "ec2-cloud-init-logs",
                "log_stream_name": "{instance_id}/cloud-init.log",
                "timezone": "UTC"
              },
              {
                "file_path": "/home/ec2-user/api.log",
                "log_group_name": "MyApplicationLogs",
                "log_stream_name": "{instance_id}-api-log",
                "timestamp_format": "%Y-%m-%dT%H:%M:%S.%fZ",
                "timezone": "UTC"
              }
            ]
          }
        }
      }
    }
  EOF
}
````

## IAM Role for EC2
````json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
````

## What is Instance Profile?
An instance profile is a container for an IAM role that enables EC2 instances to assume that role and access AWS resources.
### Purpose of an Instance Profile
An instance profile allows an EC2 instance to securely access AWS services (e.g., S3, CloudWatch) without hardcoding AWS credentials in the instance.
### Role vs. Instance Profile:
- A role specifies permissions and policies.
- An **instance profile** acts as a bridge that lets EC2 instances assume a role.
- Each EC2 instance can be associated with one instance profile.
- An instance profile must contain exactly one IAM role.