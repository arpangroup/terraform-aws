# Trigger Lambda on S3 Put Bucket 

**Use Case-1**
![img.png](img.png)

**Use Case-2**
![img_1.png](img_1.png)

**Use Case-3**
![img_2.png](img_2.png)

---

## Step1: Create S3 Bucket
````hcl
# Create an S3 bucket
resource "aws_s3_bucket" "example" {
  bucket = "example-s3-bucket"
}
````


## Step2: Create IAM Role for Lambda
- AWSLambdaBasicExecutionRole
- AmazonS3ReadOnlyAccess: Because our lambda will read the object from S3
    ````hcl
    resource "aws_iam_role" "lambda_s3_read_access_role" {
      name = "LambdaS3ReadAccessRole"
    
      assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
              Service = "lambda.amazonaws.com"
            }
          }
        ]
      })
    }
    
    resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
      role       = aws_iam_role.lambda_s3_read_access_role.name
      policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
    }
    
    resource "aws_iam_role_policy_attachment" "s3_read_only_access" {
      role       = aws_iam_role.lambda_s3_read_access_role.name
      policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
    }
    ````
  

## Step3: Create a Lambda Function with above Role (`LambdaS3ReadAccessRole`)
````hcl
resource "aws_lambda_function" "TF_example_lambda" {
  function_name = "tf_example_lambda"
  role          = "LambdaS3ReadAccessRole"
  runtime       = "python3.9"
  handler       = "lambda_function.lambda_handler"

  filename         = "./lambda_function.zip"
  source_code_hash = filebase64sha256("./lambda_function.zip")
  depends_on       = [null_resource.ZIP_LAMBDA]
}
````

## Step4: Invoke Lambda on S3 PUT Event
- Option1: Add the trigger on Lambda Console or,
- Option2: S3 Bucket **EventNotification** (Bucket > Properties > Event notifications)

````java
package com.arpan;

import com.amazonaws.auth.DefaultAWSCredentialsProviderChain;
import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.LambdaLogger;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.S3Event;
import com.amazonaws.services.lambda.runtime.events.models.s3.S3EventNotification;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3Client;
import com.amazonaws.services.s3.model.S3Object;
import com.amazonaws.services.s3.model.S3ObjectInputStream;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;

public class S3EventHandler implements RequestHandler<S3Event, Boolean> {
    private static final AmazonS3 s3Client = AmazonS3Client.builder()
            .withCredentials(new DefaultAWSCredentialsProviderChain())
            .build();
    @Override
    public Boolean handleRequest(S3Event input, Context context) {
        final LambdaLogger logger = context.getLogger();

        //check if are getting any record
        if(input.getRecords().isEmpty()){
            logger.log("No records found");
            return false;
        }
        //process the records
        for(S3EventNotification.S3EventNotificationRecord record: input.getRecords()){
            String bucketName = record.getS3().getBucket().getName();
            String objectKey = record.getS3().getObject().getKey();

            //1. we create S3 client
            //2. invoking GetObject
            //3. processing the InputStream from S3

            S3Object s3Object = s3Client.getObject(bucketName, objectKey);
            S3ObjectInputStream inputStream = s3Object.getObjectContent();
            //processing CSV - open CSV, apache CSV

            try(final BufferedReader br = new BufferedReader(new InputStreamReader(inputStream, StandardCharsets.UTF_8))){
                br.lines().skip(1)
                        .forEach(line -> logger.log(line + "\n"));
            } catch (IOException e){
                logger.log("Error occurred in Lambda:" + e.getMessage());
                return false;
            }
        }
        return true;
    }
}
````



# Lamda Setting
### 1. Bucket should on same region where you are creating Lambda
### 2. Lambda should have permission to read S3
### 3. Use DLQ/Destinations in case of error
### 4. Python Code Steps:
- Derive Bucket name and Object key from `event` object
- Create S3 Client
- Call GetObject method of S3 SDK
- Process the inputStream