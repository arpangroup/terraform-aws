## Important Terraform Commands:
1. Simple EC2 Instance Setup
2. Setup VPC (subnet + IGW + RT + SG)
3. EC2 + S3 + Static Website
4. EC2 + S3 + SpringBoot Jar + DynamoDB
5. 




````console
terraform init         # Download Dependencies
terraform plan         # Preview changes before apply
terraform apply        # Create Resources
terraform destroy      # Destroy Resources

terraform validate     # Validate Syntax
terraform fmt          # Format/Beautify Code
````


## Recommended Terraform Folder Structure
A scalable folder structure for Terraform projects:

````css
├── modules/                # Reusable modules
│   ├── vpc/                # Example module: VPC setup
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   ├── ec2/                # Example module: EC2 instances
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   ├── rds/                # Example module: RDS database
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
├── environments/           # Separate configurations for environments
│   ├── dev/                # Development environment
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── terraform.tfvars
│   ├── staging/            # Staging environment
│   │   ├── main.tf
│   │   ├── terraform.tfvars
│   ├── prod/               # Production environment
│       ├── main.tf
│       ├── terraform.tfvars
├── terraform.tfvars        # Global variables (optional)
├── backend.tf              # Backend configuration for state
├── provider.tf             # Provider configurations
├── variables.tf            # Global variable definitions
├── outputs.tf              # Global output definitions
└── README.md               # Documentation

````

## Key Elements
1. Modules:
-- Reusable blocks of Terraform code.
-- Encapsulate resource definitions and variable logic.
2. Environment-Specific Configurations:
-- Separate directories for each environment (`dev`, `staging`, `prod`).
-- Use `terraform.tfvars` to define environment-specific values.
3. Global Configurations:
-- Define backend, provider, and common variables at the root level.
4. State File Management:
Use `backend.tf` to configure remote state for collaboration.
````
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
  }
}

````
5. Documentation:
-- Maintain a `README.md` to document module usage, variables, and setup instructions.


## Example Workflow
1. Navigate to the desired environment:
````bash
cd environments/prod
````
2. Initialize Terraform:
````bash
terraform init
````
3. Plan infrastructure changes:
````bash
terraform plan -var-file="terraform.tfvars"
````
4. Apply the changes:
````bash
terraform apply -var-file="terraform.tfvars"
````



## 8 Terraform Best Practices that will improve your TF workflow immediately
1. Manipulate state only through TF commands
-- **Why:** Directly editing Terraform state files (terraform.tfstate) can corrupt the file and lead to inconsistent or unintended behavior.
-- **How:** Use commands like `terraform state mv`, `terraform state rm`, and `terraform state import` for safe state manipulation.
-- Always use terraform plan before applying changes to verify the desired state.
2. Remote State
-- **Why:** Storing state locally is risky (e.g., loss of state or conflicts in collaborative environments). A remote state ensures centralized and secure management.
-- **How:** Use remote backends like S3, Terraform Cloud, or Consul.
-- Example using S3
````
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
  }
}

````

3. State Locking
-- **Why:** Prevents multiple users or processes from making simultaneous updates to the state file, avoiding conflicts.
-- **How:** Use a locking mechanism provided by your backend, such as DynamoDB with S3
 -- Create a DynamoDB table to track locks.
 -- Enable `state locking` in your backend configuration.
4. Back up State File
-- Losing your state file can result in an inability to manage your infrastructure.
5. Use 1 State per Environment
-- Sharing a single state across multiple environments (e.g., dev, staging, prod) can lead to accidental modifications and is hard to manage.
-- Create separate state files for each environment by configuring different backend keys or directories:
````
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "dev/terraform.tfstate"  # Use 'staging/' or 'prod/' for other environments
    region = "us-east-1"
  }
}

````
6. Host TF code in Git repository
7. CI for TF Code 
-- Example GitHub Actions Workflow:
````yaml
name: Terraform CI
on:
  push:
    branches:
      - main
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.4.0
      - name: Validate Terraform
        run: terraform validate
      - name: Format Check
        run: terraform fmt -check

````
8. Execute TF only in an automated build
-- Running Terraform manually increases the risk of human error. Automating execution ensures consistency, auditability, and predictable outcomes.
-- Use CI/CD pipelines to run `terraform plan` and `terraform apply` based on approved changes.



## Terraform Module
-- A module is a container for multiple resources that are used together. It is essentially a way to organize and reuse Terraform configurations.
-- Example
````
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"
  cidr    = "10.0.0.0/16"
}

````

## Terraform Provider
A provider is a plugin that enables Terraform to interact with APIs of cloud platforms or other services.

-- Serves as the bridge between Terraform and the external system, defining how to manage resources.
-- Handles API calls to provision, update, or destroy resources.
-- Must be configured before resources or modules can use it.
-- Example
````
provider "aws" {
  region = "us-east-1"
}

````


Key Differences:

| Aspect  | Module | Provider |
| ------------- | ------------- |------------- |
| Purpose | Organizes and reuses resources   | Manages API interaction   |
| Scope | Focuses on resource structure   | Focuses on cloud/service APIs   |
| Dependency | Can use multiple providers   | Independent of modules   |
| Examples | VPC, Database, Compute modules   | AWS, Azure, GCP providers   |
