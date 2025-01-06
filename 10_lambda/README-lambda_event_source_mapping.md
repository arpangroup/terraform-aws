## Understanding Lambda Event Source Mapping for SQS: How Lambda Polls and Processes Messages

## Does SQS Push Messages to a Lambda Function When Using Event Source Mapping?
No, Amazon SQS (Simple Queue Service) does not natively push messages to AWS Lambda functions. Instead, Lambda can poll SQS for messages and process them. However, you can set up an event source mapping to enable Lambda to poll an SQS queue and automatically trigger the Lambda function when new messages are available.

Here’s how it works:
1. **Event Source Mapping**: You create an event source mapping in AWS Lambda that associates a specific SQS queue with your Lambda function. This mapping tells Lambda to poll the SQS queue for messages.
2. **Polling**: Lambda continuously polls the SQS queue for new messages. When messages are available, Lambda retrieves them in batches (up to 10 messages per batch, depending on your configuration).
3. **Triggering**: Once Lambda retrieves messages from the queue, it triggers your Lambda function, passing the messages as an event payload.
4. **Processing**: Your Lambda function processes the messages. If the function successfully processes a message, Lambda deletes it from the queue. If the function fails to process a message, Lambda retries based on the queue's redrive policy and visibility timeout settings.


### Key Points:
- **No Native Push**: SQS does not push messages to Lambda. Instead, Lambda pulls messages from SQS.
- **Event Source Mapping**: You need to configure an event source mapping to enable Lambda to poll the SQS queue.

---


## How Does Lambda Poll SQS for Messages When It’s Not Actively Running?
AWS Lambda **does not need to be "running" continuously** to poll Amazon SQS. Instead, Lambda uses an **internal event source mapping service** to poll the SQS queue on your behalf. This service is managed by AWS and operates independently of your Lambda function's execution. Here's how it works:

### How Lambda Polls SQS Without Being "Running"
1. **Event Source Mapping**:
- When you create an **event source mapping** between an SQS queue and a Lambda function, AWS Lambda's internal service starts polling the SQS queue.
- This polling is done by AWS's infrastructure, not by your Lambda function itself. It operates in the background and is fully managed by AWS.
2. **Polling Mechanism**:
- The event source mapping service continuously polls the SQS queue for new messages.
- Polling happens even when your Lambda function is not actively running.
- If messages are found in the queue, the event source mapping service triggers your Lambda function and passes the messages to it.
3. **Lambda Function Invocation**:
- When messages are available in the queue, the event source mapping service invokes your Lambda function.
4. **Scaling**:
- If multiple messages are available in the queue, Lambda can scale out and invoke multiple instances of your function concurrently (up to the concurrency limit you configure).
- Each instance processes a batch of messages independently.

### Key Points::
- **No Continuous Execution**: Lambda does not need to run continuously to poll SQS. The polling is handled by AWS's internal event source mapping service.
- **Automatic Scaling**: Lambda automatically scales the number of function instances based on the number of messages in the queue.

---

## Cost Considerations (SQS Polling Costs):
When using **Amazon SQS (Simple Queue Service)** with **AWS Lambda**, the polling mechanism incurs costs primarily related to SQS API requests. Here's a breakdown of the costs associated with SQS polling:
- **SQS Polling Costs**: SQS charges for API requests, including `ReceiveMessage` calls made by the event source mapping service. However, AWS optimizes the polling to minimize costs.
- **Lambda Execution Costs**: You are charged only for the time your Lambda function runs to process messages, not for the polling itself.

#### SQS API Request Costs:: 
- SQS charges **$0.40 per million requests** after the Free Tier (1 million requests per month are free).
- Each `ReceiveMessage` call counts as one request, regardless of the number of messages retrieved (up to 10 messages per call).

---

## Example Cost Calculation:
Suppose:
- Your application processes **10 million messages per month**.
- Lambda retrieves messages in batches of 10, resulting in **1 million `ReceiveMessage` calls**.
- Each message is 10 KB in size.

### Cost Breakdown:
- **SQS API Requests**:
  - 1 million requests = Free Tier (no cost).
- **Data Transfer Out**:
  - 10 million messages × 10 KB = 100 GB.
  - 100 GB - 1 GB (Free Tier) = 99 GB × 0.09 / GB = ∗∗8.91**.
- **Lambda Execution**:
  - Depends on the duration and memory usage of your function.













