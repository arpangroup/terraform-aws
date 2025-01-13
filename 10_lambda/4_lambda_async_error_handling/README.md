# Asynchronous Error:
- Retry 2 times after failure
- Destinations
    - DLQ or
    - **Destinations**(`onSuccess` or `onFailure`)
- Configuration:
    - MaximumRecordAge
    - MaximumRetryAttempts
    - BisectBatchOnFunctionError

## Amazon SQS Event Source:
**Retry behavior**: until message expires
- Default: retry all message in batch
- Function can delete completed messages


## Step Function Event Source:
- Retry behavior  : Configurable
- Specify using **Retry**, by error type


