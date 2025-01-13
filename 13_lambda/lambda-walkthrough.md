# AWSLambda Walkthrough
![lambda_1.png](../diagrams/lambda_1.png)
![lambda_2.png](../diagrams/lambda_2.png)
![lambda_3.png](../diagrams/lambda_3.png)

Once the Lambda creation is successful:
![lambda_4.png](../diagrams/lambda_4.png)

Configurations:
![lambda_5.png](../diagrams/lambda_5.png)

Trigger: (APIGW, ALB, CloudFront, COdeCommit, CloudWatchLog, EventBridge, S3, SNS, SQS, DynamoDB, Kinesis....)
![lambda_6.png](../diagrams/lambda_6.png)


### Permissions
Execution role:
![lambda_7.png](../diagrams/lambda_7.png)
![lambda_8.png](../diagrams/lambda_8.png)

**Resource-based policy statements**: <br/>
Resource-based policies grant other AWS accounts and services permissions to access your Lambda resources.
![lambda_9.png](../diagrams/lambda_9.png)
![lambda_10.png](../diagrams/lambda_10.png)
![lambda_11.png](../diagrams/lambda_11.png)
![lambda_12.png](../diagrams/lambda_12.png)

### Destination:
![lambda_13.png](../diagrams/lambda_13.png)
![lambda_14.png](../diagrams/lambda_14.png)

Asynchronous invocation:
![lambda_15.png](../diagrams/lambda_15.png)