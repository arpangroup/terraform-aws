# SQS
- **Standard Vs [FIFO Queue](README-sqs_fifo.md)
- [BacBackpressure control](README-sqs_backpressure.md)
- Dead Letter Queue
- **Permissions**: 
  - CreateQueue, TagQueue, SetQueueAttributes
  - **Resource**: Resource = "arn:aws:sqs:us-east-1:*"


## Why use SQS over API call to other service?
- **Backpressure Control**: Consumers can choose the rate of processing
- **Fire and Forget**: Publishers have no insight into client processing
- **Eventual Guaranteed Processing**: Great for async or non-realtime apps
- **Application Decoupling**:  Decouples service dependencies
![sqs_vs_api.png](../diagrams/sqs_vs_api.png)



## Standard Vs FIFO Queue
![sqs_standard_vs_fifo.png](../diagrams/sqs_standard_vs_fifo.png)

## Common Patterns with SQS
![sqs_common_patterns.png](../diagrams/sqs_common_patterns.png)

## Important Details of SQS Queues:
- Many threads / processes can **poll** a Queue at once
- Only a single thread / process ca **process** a message at once
- **Long Polling** is supported and encouraged
- Support for **cross account** publishing / processing
- **256 KB** maximum payload size per message
- **Dead Letter Queues** (DLQ) can helps store failed messages for later processing