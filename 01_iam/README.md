## AWS Inline Policy vs Managed Policy
- **Advantages of Inline Policies**:
  - **Granular Control**: Allows fine-grained control for specific IAM entities.
  - **No Reuse Needed**: Useful when the policy is only needed for a single user, group, or role.
- **Disadvantages**:
  - **Not Reusable**: Inline policies can't be reused across other IAM entities.
  - **Management Overhead**: It can become harder to manage when multiple entities require the same policy. Managed policies are more scalable in such cases.

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
---

## `aws_iam_role` vs `aws_iam_role_policy` vs `aws_iam_policy` vs `aws_iam_policy_attachment` vs `aws_iam_role_policy_attachment`
In Terraform, the various AWS IAM resources serve different purposes for managing roles and policies. Here's a quick breakdown:

### 1. `aws_iam_role`
- **Purpose**: Creates an IAM role that can be assumed by trusted entities (e.g., AWS services or users).
- **Key Use Case**: Define the trust relationship and permissions boundary for an IAM role.
- **Example Usage:**
    ````hcl
    resource "aws_iam_role" "example" {
      name = "example-role"
      assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
          Action = "sts:AssumeRole"
          Principal = {
            Service = "ec2.amazonaws.com"
          }
          Effect = "Allow"
        }]
      })
    }
    ````

### 2. `aws_iam_role_policy`
- **Purpose**: Attaches an inline policy directly to an IAM role.
- **Key Use Case**: Use when the policy is specific to a single role and not intended for reuse.
- **Example Usage:**
    ````hcl
    resource "aws_iam_role_policy" "example" {
      name   = "example-policy"
      role   = aws_iam_role.example.name
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
          Action   = "s3:ListBucket"
          Effect   = "Allow"
          Resource = "*"
        }]
      })
    }    
    ````

### 3. `aws_iam_policy`
- **Purpose**: Creates a standalone, reusable managed IAM policy.
- **Key Use Case**: Use when a policy needs to be shared across multiple roles or users.
- **Example Usage:**
  ````hcl
  resource "aws_iam_policy" "example" {
    name   = "example-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Action   = "s3:ListBucket"
        Effect   = "Allow"
        Resource = "*"
      }]
    })
  }
  ````

### 4. `aws_iam_policy_attachment`
- **Purpose**: Attaches a managed policy (`aws_iam_policy`) to multiple IAM users, roles, or groups
- **Example Usage:**
  ````hcl
  resource "aws_iam_policy_attachment" "example" {
    name       = "example-attachment"
    policy_arn = aws_iam_policy.example.arn
    roles      = [aws_iam_role.example.name]
    users      = ["example-user"]
  }
  ````

### 5. `aws_iam_role_policy_attachment`
- **Purpose**: Attaches a managed policy (e.g., AWS-provided or `aws_iam_policy`) to a specific IAM role.
- **Example Usage:**
  ````hcl
    resource "aws_iam_role_policy_attachment" "example" {
      role       = aws_iam_role.example.name
      policy_arn = aws_iam_policy.example.arn
    }
  ````

---

## Summary of Use Cases

| Resource                        | Use Case                                             |
|---------------------------------|------------------------------------------------------|
| `aws_iam_role`                  | Create roles with trust relationships.               |
| `aws_iam_role_policy`           | Inline policies tied to a specific role.             |
| `aws_iam_policy`                | Reusable, standalone policies for multiple entities. |
| `aws_iam_policy_attachment`     | Attach a policy to multiple entities at once.        |
| `aws_iam_role_policy_attachment`| Attach a managed policy to a single role.            |




