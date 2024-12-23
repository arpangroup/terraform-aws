/*# Provide CloudWatch Agent Configuration File
resource "aws_s3_bucket" "agent_config" {
  bucket = "cloudwatch-agent-config"
}

resource "aws_s3_bucket_object" "agent_config_file" {
  bucket = aws_s3_bucket.agent_config.bucket
  key    = "amazon-cloudwatch-agent.json"
  content = <<-EOF
    {
      "logs": {
        "logs_collected": {
          "files": {
            "collect_list": [
              {
                "file_path": "/var/log/messages",
                "log_group_name": "/ec2/logs/example",
                "log_stream_name": "{instance_id}"
              }
            ]
          }
        }
      }
    }
  EOF
}*/