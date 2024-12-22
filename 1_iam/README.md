## What is Instance Profile?
An instance profile is a container for an IAM role that enables EC2 instances to assume that role and access AWS resources.
### Purpose of an Instance Profile
An instance profile allows an EC2 instance to securely access AWS services (e.g., S3, CloudWatch) without hardcoding AWS credentials in the instance.
### Role vs. Instance Profile:
- A role specifies permissions and policies.
- An **instance profile** acts as a bridge that lets EC2 instances assume a role.
- Each EC2 instance can be associated with one instance profile.
- An instance profile must contain exactly one IAM role.

**Example of how an instance profile is defined and used**
````hcl
# Define the Role
resource "aws_iam_role" "example" {
  name = "example-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = { Service = "ec2.amazonaws.com" },
        Action = "sts:AssumeRole"
      },
    ]
  })
}

# Attach Policies to the Role
resource "aws_iam_role_policy_attachment" "example" {
  role       = aws_iam_role.example.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess" # Example policy
}


# Create the Instance Profile
resource "aws_iam_instance_profile" "example" {
  name = "example-instance-profile"
  role = aws_iam_role.example.name
}

# Associate Instance Profile with EC2
resource "aws_instance" "example" {
  ami           = "ami-0c02fb55956c7d316" # Replace with your AMI
  instance_type = "t2.micro"

  iam_instance_profile = aws_iam_instance_profile.example.name
}
````