# Configure EC2 instance logs to be sent to CloudWatch
To configure EC2 instance logs to be sent to CloudWatch, follow these steps:<br/>
#### [Install and run the CloudWatch agent](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/install-CloudWatch-Agent-commandline-fleet.html)
#### [Download Word Document - CloudWatch-AWS CLI](../diagrams/CloudWatch.pdf)

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

## Step5: Verify Logs in CloudWatch
1. Go to the **CloudWatch Management Console**.
2. Navigate to **Log Groups** and confirm your logs (e.g., `EC2InstanceLogs`) are being received.
3. Check the log streams (e.g., based on `instance_id`).

## Step6: Integrate Application Log like Spring
To integrate your application logs (stored in `/home/ec2-user/api.log`) with CloudWatch, follow these steps:

### Step6.1: Update the CloudWatch Agent Configuration
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

### Step6.2: Start or Restart the CloudWatch Agent
Apply the updated configuration:
````bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a start -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s
````
If the agent is already running, restart it:
````bash
sudo systemctl restart amazon-cloudwatch-agent
````

### Step6.3: Verify Log Upload
Check the CloudWatch Agent logs for issues:
````bash
tail -f /opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log
````
Go to the CloudWatch Management Console:
- Navigate to **Log Groups** > **MyApplicationLogs**.
- Confirm logs from `/home/ec2-user/api.log` are appearing in the log stream.

### Step6.4: Set Up Log Rotation (Optional)
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

## Optional: Create LogGroup using Terraform
````hcl
# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "TF_LOG_GROUP" {
  name              = "/tf-example/log-group"
  retention_in_days = 7 # how long log data is retained in the group before being automatically deleted.

  tags = {
    Environment = "Dev"
  }
}
````


## S3 CloudWatch Agent Configuration File
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