resource "aws_iam_policy" "TF_IAM_POLICY" {
  name = "tf-ECS-execution-policy"
  role = aws_iam_role.TF_IAM_ROLE.id
  policy = file("${path.module}/iam_policy.json")

  # Terraform's "jsoncode"function converts a
  # Terraform expression result to valid JSON syntax
  /*policy = jsondecode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe"
        ]
        Effect = "Allow"
        Resource = "*"
      },
    ]
  })*/
}

