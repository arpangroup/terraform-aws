# CloudWatch Metrics

## Scenario: Monitoring a Web Application
You run an e-commerce website hosted on **AWS Elastic Load Balancer** (ELB) and **EC2 instances**. You want to ensure your application is performing well and proactively address potential issues.

### Relevant CloudWatch Metrics:
1. ### ELB Metrics
   - **RequestCount**: Tracks the number of requests handled by the load balancer
     - Example: During Black Friday, RequestCount spikes from an average of 1,000 requests per minute to 10,000 requests per minute. This indicates increased traffic.
   - **Latency**: Measures the time taken for requests to be processed.
     - Example: If Latency increases from 200ms to 1s, it could indicate backend issues or high traffic.
2. ### EC2 Metrics
   - **CPUUtilization**: Shows the percentage of CPU capacity in use.
     - Example: If an EC2 instance's CPUUtilization consistently exceeds 85%, it may indicate the need for scaling or performance optimization.
   - DiskReadOps and DiskWriteOps: Measure the number of disk read and write operations.
     - Example: A sudden drop in DiskWriteOps may signal disk health issues or connectivity problems.
3. ### DynamoDB Metrics
    - **ConsumedReadCapacityUnits** and **ConsumedWriteCapacityUnits**: Reflect the database usage.
      - Example: If the ConsumedWriteCapacityUnits hit the provisioned capacity limit, write requests might throttle.
4. ### Application Metrics (Custom)
   - **CartCheckoutFailures**: Custom metric tracking the number of failed checkouts.
     - Example: If CartCheckoutFailures spike, it might indicate a payment gateway issue.