# AWS Lambda Asynchronous Invocation
AWS Lambda asynchronous invocation is a feature where the function is invoked in an event-driven, decoupled manner. 

Instead of waiting for the Lambda function to return a response, **the event is queued**, and the function returns immediately after it has been queued for execution. 

The actual execution of the Lambda function happens in the background, and you don't get an immediate result.


## Key Characteristics of Asynchronous Invocation
1. **Event Queueing**
2. **Automatic Retry**
3. **Return Handling**
4. **Event Source** <br/> Common services that trigger asynchronous invocations include:
   - Amazon S3 (e.g., when an object is uploaded)
   - Amazon SNS (Simple Notification Service)
   - Amazon DynamoDB Streams
   - CloudWatch Events
   - Amazon EventBridge 

> **Event Ordering**: Lambda does not guarantee the order in which events are processed in asynchronous invocation. This is because the events may be handled by different instances of the Lambda function.