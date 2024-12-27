# AWS Scheduler

## 1. Reader Lambda:
### 1.1. Read data from an S3 bucket file.
- Trigger:
  - Scheduler (AWS EventBridge) or
  - External Endpoint (AWS Lambda Function URL).
- Improvement Suggestion:
  - Use an SQS queue instead of directly invoking downstream services to decouple processing.
  - Use **batch processing** to read multiple lines/records if possible for efficiency.

### 1.2. Push Data into SQS:
- Decouples the reader from downstream services.
- Supports concurrency and scaling.
- Ensures retry on failure, reducing chances of data loss.


## 2. Processor Step Function:
**Workflow**
1. **Trigger**: Consume messages from SQS.
2. **Processor Lambda**: Processes the data.
3. **Retry Mechanism**:
   - Use the built-in retry policies of Step Functions for transient errors.
   - Push failed records to a Dead Letter Queue (DLQ) for later analysis.
4. **Success Case**: Pass processed records to a Writer Lambda.
5. **Improvement Suggestion:**
   - Instead of pushing data to another queue, let the Step Function directly invoke the **Processor Lambda**. This simplifies the workflow and reduces latency.
   - For scalability, ensure the SQS queue and Processor Lambda are configured to handle **high-concurrency processing** (e.g., Lambda reserved concurrency settings).


## 3. Writer Lambda for DynamoDB:
- **Purpose**: Write processed data to DynamoDB.
- **Trigger**: Step Function output directly.
- **Improvement Suggestion**: 
  - Avoid introducing another SQS queue between Step Function and Writer Lambda unless:
    - You need to decouple DynamoDB writes from Step Functions for independent scaling.
    - There is a possibility of high DynamoDB throttling.
  - Use **DynamoDB BatchWriteItem** for bulk inserts if applicable.


## 4. Dead Letter Queues (DLQ):
- **For SQS Queues**: Add DLQs to capture unprocessable messages.
- **For Step Function Tasks**: Configure DLQs to capture retries exceeding the limit.
- **For Lambda**: Configure Lambda's built-in DLQ feature to capture invocation failures.