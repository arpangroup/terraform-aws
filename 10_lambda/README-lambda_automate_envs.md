# AAutomate Environment Variables

### Example Using Terraform:
````hcl
resource "aws_lambda_function" "my_lambda" {
  .......
  environment {
    variables = {
      ENVIRONMENT = "production"
      DB_HOST     = "database.example.com"
      DB_PORT     = "3306"
    }
  }
}
````

### Example Using AWS CLI:
````bash
aws lambda create-function \
  --function-name my_lambda_function \
  --runtime python3.9 \
  --role arn:aws:iam::account-id:role/service-role/MyLambdaRole \
  --handler lambda_function.lambda_handler \
  --zip-file fileb://lambda_function.zip \
  --environment Variables={ENVIRONMENT=production,DB_HOST=database.example.com,DB_PORT=3306}
````

To update environment variables:
````bash
aws lambda update-function-configuration \
  --function-name my_lambda_function \
  --environment Variables={ENVIRONMENT=staging,DB_HOST=staging-db.example.com,DB_PORT=3306}
````

### Example Using AWS CloudFormation:
````yaml
Resources:
  MyLambdaFunction:
    Type: "AWS::Lambda::Function"
    Properties:
      FunctionName: "my_lambda_function"
      Runtime: "python3.9"
      Handler: "lambda_function.lambda_handler"
      Role: !GetAtt MyLambdaRole.Arn
      Code:
        S3Bucket: "my-lambda-bucket"
        S3Key: "lambda_function.zip"
      Environment:
        Variables:
          ENVIRONMENT: "production"
          DB_HOST: "database.example.com"
          DB_PORT: "3306"

  MyLambdaRole:
    Type: "AWS::IAM::Role"
    Properties:
      AssumeRolePolicyDocument:
        Version: "2012-10-17"
        Statement:
          - Effect: "Allow"
            Principal:
              Service: "lambda.amazonaws.com"
            Action: "sts:AssumeRole"
      Policies:
        - PolicyName: "lambda-logs"
          PolicyDocument:
            Version: "2012-10-17"
            Statement:
              - Effect: "Allow"
                Action:
                  - "logs:CreateLogGroup"
                  - "logs:CreateLogStream"
                  - "logs:PutLogEvents"
                Resource: "*"

````

## Tips for Automation:
### 1. Use Secrets Manager or Parameter Store:
- Avoid hardcoding sensitive data (e.g., database credentials).
- Fetch sensitive values dynamically at runtime or inject them securely during deployment.

Example with Parameter Store in Terraform:
````hcl
data "aws_ssm_parameter" "db_password" {
  name = "/my-app/db-password"
}

resource "aws_lambda_function" "my_lambda" {
  environment {
    variables = {
      DB_PASSWORD = data.aws_ssm_parameter.db_password.value
    }
  }
}

````