
# AWS DynamoDB Pricing

### AWS DynamoDB Free Tier Pricing

| **Feature**                  | **Free Tier Allowance**                                   |
|------------------------------|---------------------------------------------------------|
| **Read Capacity Units (RCUs)** | 25 RCUs (Approx. 200 million requests per month)         |
| **Write Capacity Units (WCUs)** | 25 WCUs (Approx. 25 million requests per month)          |
| **Storage**                  | 25 GB                                                   |
| **On-Demand Mode**           | 2.5 million read requests and 1 million write requests per month |
| **Global Tables**            | 25 replicated RCUs and WCUs                             |
| **Streams**                  | 2.5 million stream read requests per month              |
| **Data Transfer**            | 1 GB of data transfer out to the internet per month     |

### Cost Beyond Free Tier

| **Feature**                  | **Pricing**                                              |
|------------------------------|---------------------------------------------------------|
| **Storage**                  | $0.25 per GB per month                                   |
| **Provisioned Read Capacity**| $0.00013 per RCU per hour                                |
| **Provisioned Write Capacity**| $0.00065 per WCU per hour                                |
| **On-Demand Read Requests**  | $1.25 per 1 million requests                             |
| **On-Demand Write Requests** | $1.25 per 1 million requests                             |
| **DynamoDB Streams**         | $0.02 per 100,000 stream read requests                   |
| **Global Tables**            | Additional charges for replicated RCUs and WCUs in each region |
| **Data Transfer**            | Charges apply for data transfer out exceeding 1 GB per month. Rates vary by region. |

## Additional Notes
- Pricing varies slightly based on AWS region. Check the [DynamoDB Pricing page](https://aws.amazon.com/dynamodb/pricing/) for regional details.
- Costs scale with usage. Monitor usage to avoid unexpected charges.

