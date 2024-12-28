resource "aws_iam_role" "TF_IAM_ROLE" {
  name = "tf-ECS-execution-role"
  assume_role_policy = file("${path.module}/templates/resources/iam_role.json")

  /*assume_role_policy = jsondecode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })*/
}

