## AWS Lambda Function Limits: Maximum per Account & Management Tips

AWS imposes certain limits on the number of Lambda functions you can create in a single AWS account. As of the latest information (October 2023), the default limit for the number of Lambda functions per AWS account is **1,000 per region**. This includes all versions and aliases of functions.
- **Default Limit**: 1,000 Lambda functions per region per account.
- **Scope**: This limit applies to the total number of functions, including all versions and aliases.
- **Request for Increase**: If you need to create more than 1,000 Lambda functions in a region


## Other Related Limits:
- **Concurrent Executions**: AWS Lambda also has a limit on the number of concurrent executions across all functions in a region. The default is **1,000 concurrent executions**, but this can be increased upon request.

- **Storage Limit**: Each AWS account has a total storage limit for Lambda functions and their layers (up to **75 GB** per region).


### How to Check Your Current Limits:
1. Open the AWS Lambda Console.
2. Navigate to the Account Settings section.
3. View the current limits for your account.