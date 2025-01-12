# Trigger Lambda on S3 Put Bucket
- Option1: Add the trigger on Lambda Console or (not possible using Terraform),
- Option2: S3 Bucket **EventNotification** (`Bucket > Properties > Event notifications`)
- Option3: EventBridge rule to capture S3 PutObject events

### Option1: using AWS console: (Not possible using Terraform)
1. Add Trigger: Select S3 > BucketName | EventTypes==> PUT | Check I acknowledge > Add
2. Add following policy to IAM role to allow S3 to invoke the Lambda function
   - Lambda function > Configuration > Permissions > Execution role.
   - Add following policy to the IAM role
    ````json
    {
      "Effect": "Allow",
      "Action": "lambda:InvokeFunction",
      "Resource": "arn:aws:lambda:us-east-1:123456789012:function:example-lambda-function",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Condition": {
       "StringEquals": {
        "AWS:SourceAccount": "123456789012"
       }
     }
    }
    ````
   The same permission can be add using below terraform code:
    ````hcl
    resource "aws_lambda_permission" "allow_s3" {
      statement_id  = "AllowExecutionFromS3"
      action        = "lambda:InvokeFunction"
      function_name = aws_lambda_function.TF_LAMBDA_EXAMPLE.function_name
      principal     = "s3.amazonaws.com"
      source_arn    = "arn:aws:s3:::tf-example-bucket123"
    }
    ````

### Option2: Configure S3 Bucket EventNotification on S3 Bucket
````hcl
resource "aws_s3_bucket_notification" "example" {
  bucket = aws_s3_bucket.example.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.TF_example_lambda.arn
    events              = ["s3:ObjectCreated:Put"]

    filter_suffix = ".txt" # Optional: Trigger only for .txt files
  }

  depends_on = [
    aws_lambda_permission.allow_s3_invoke
  ]
}
````


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

---

## S3 Event Example:
````json
{
   "eventVersion": "2.1",
   "eventSource": "aws:s3",
   "awsRegion": "us-east-1",
   "eventTime": "2025-01-09T18:48:38.476Z",
   "eventName": "ObjectCreated:Put",
   "userIdentity": {
      "principalId": "AWS:AIDAXEVXYWT4BQ7Q2I3JL"
   },
   "requestParameters": {
      "sourceIPAddress": "103.120.51.119"
   },
   "responseElements": {
      "x-amz-request-id": "GKXRZAQPGZVJ2V0Y",
      "x-amz-id-2": "2vJ/k22IDaBxgoM5ws1Rgalx0GW3DmngD+Ts3YuE28tx50FsUc5u+lzD747/szttjCQfYp1ygMPifImruzUQ9RqLte06qHmVAxGfVQWwof4="
   },
   "s3": {
      "s3SchemaVersion": "1.0",
      "configurationId": "6c446218-f819-4707-a5b6-00ddfb6a8bce",
      "bucket": {
         "name": "tf-example-bucket123",
         "ownerIdentity": {
            "principalId": "AJSMJUXC7HQUP"
         },
         "arn": "arn:aws:s3:::tf-example-bucket123"
      },
      "object": {
         "key": "elk.png",
         "size": 186552,
         "eTag": "66da74717343fc02774e782674ef0077",
         "sequencer": "0067801A065FBDB40F"
      }
   }
}
````

---

## SQS Event Example:
````json
{
   "messageId": "51f8efe4-4495-4689-a046-b26481ca64c9",
   "receiptHandle": "SDSDSSDSNBVNDCHGDMN",
   "body": "Hello World",
   "attributes": {
      "ApproximateReceiveCount": "1",
      "SentTimestamp": "1736615169505",
      "SenderId": "AGHGNYVNDGFSOSYREN",
      "ApproximateFirstReceiveTimestamp": "1736615169569"
   },
   "messageAttributes": {},
   "md5OfBody": "b30a8dc266e0754105b9x756712349be72e3fe5",
   "eventSource": "aws:sqs",
   "eventSourceARN": "arn:aws:sqs:us-east-1:<ACCOUNT_ID>:tf-example-queue",
   "awsRegion": "us-east-1"
}
````
