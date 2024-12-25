# AWS Lambda Concurrency
Concurrency in Lambda refers to the **number of function** invocations that are being **processed simultaneously**. Each concurrent execution is handled by a separate instance of the Lambda function.

> **Scaling**: Lambda automatically scales by creating new instances to handle incoming requests, up to the concurrency limit. If the concurrency limit is reached, additional requests are throttled.

## Concurrency Limitations:
AWS enforces two types of concurrency limits:
- **Account Level Limit**: This is the total concurrency limit for all functions within an AWS account in a region.
- **Function Level Reserved Concurrency**: You can reserve a specific portion of the account-level concurrency for a single function.


## Types of Concurrency in Lambda
1. Unreserved Concurrency
   - The default setting where all functions share the account's concurrency pool.
   - Functions can scale as needed, but they might compete for resources.
2. Reserved Concurrency
   - Allows setting a fixed concurrency for a specific function.
   - Guarantees the availability of resources for critical functions.
   - Prevents one function from consuming all available concurrency.
3. Provisioned Concurrency
   - Keeps a certain number of instances initialized and ready to process requests.
   - Reduces cold starts by pre-warming instances.
   - Useful for latency-sensitive applications.


### Reserved Concurrency Configuration:
````hcl
resource "aws_lambda_function" "my_lambda" {
  .......
}

resource "aws_lambda_function_concurrency" "my_lambda_concurrency" {
  function_name = aws_lambda_function.my_lambda.function_name
  reserved_concurrent_executions = 10  # Set the number of reserved concurrency
}

````

### Provisioned Concurrency Configuration
````hcl
resource "aws_lambda_function" "my_lambda" {
  .......
}

resource "aws_lambda_provisioned_concurrency_config" "my_provisioned_concurrency" {
  function_name              = aws_lambda_function.my_lambda.function_name
  qualifier                  = "$LATEST"  # You can use a version or alias here
  provisioned_concurrent_executions = 10  # Number of pre-warmed instances
}
````



## Concurrency Calculations
- **Account Concurrency**: <br/>
  Total Concurrency = Sum of concurrent executions across all functions.
- **Function Concurrency:** <br/>
  For a function with reserved concurrency, its maximum concurrency is limited to that reserved value. For unreserved concurrency, it uses available concurrency from the account's pool.

## Throttling in Lambda
- When a function exceeds its concurrency limit, AWS throttles additional requests.
- **Behavior:**
  - For synchronous invocations: The caller receives a `429 Too Many Requests` error.
  - For asynchronous invocations: AWS retries the invocation with an exponential backoff.

## Pricing for Lambda Concurrency
There isn't a specific charge solely for "extra concurrency" itself; instead, the pricing is determined by the number of **requests** and the **duration** that your function is running, along with any costs incurred for **provisioned concurrency**.
1. **Request Charges** <br/> Lambda charges per request, regardless of the number of concurrent executions:
   - **First 1 million requests per month**: Free.
   - **After the free tier**: $0.20 per 1 million requests.
2. **Duration Charges** <br/> Lambda charges based on the execution duration of your function, which is the time it takes from when your function starts executing until it returns or terminates. The charge is calculated in **100ms increments**.
   - **First 400,000 GB-seconds per month**: Free.
   - **After the free tier**: $0.00001667 per GB-second. <br/> 

    ### Example of Duration Pricing:
   If you allocate 512 MB of memory to a function, and it runs for 1 second:
   - **Memory usage**: 0.5 GB-seconds (512 MB = 0.5 GB)
   - **Cost**: 0.5 GB-seconds × $0.00001667 per GB-second = $0.000008335


## Best Practices
1. **Set Reserved Concurrency for Critical Functions** <br/> Prevents these functions from being throttled due to resource contention.
2. **Use Provisioned Concurrency for Low-Latency Needs** <br/> Reduces cold start latency for performance-sensitive functions.
3. **Monitor and Optimize** <br/> Use AWS CloudWatch to monitor Lambda metrics like `ConcurrentExecutions`, `Throttles`, and `ProvisionedConcurrencyUtilization`.
4. **Use Batching and Queueing** <br/> For high-throughput systems, use services like SQS, SNS, or Kinesis to buffer requests and control concurrency.
5. **Implement Retry Logic** <br/> Handle throttling gracefully in the caller by implementing retry mechanisms with exponential backoff.