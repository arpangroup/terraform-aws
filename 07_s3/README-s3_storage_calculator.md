
## S3 Storage Calculator

This table helps estimate your Amazon S3 storage costs based on the storage class, retrieval costs, and other associated fees.

| **Storage Class**           | **Price per GB/month** | **Retrieval Cost**                          | **Request Cost (per 1,000 requests)** | **Data Transfer Cost**                        |
|-----------------------------|------------------------|---------------------------------------------|---------------------------------------|-----------------------------------------------|
| **S3 Standard**              | $0.023                 | No cost for retrieval                       | PUT, COPY, POST, LIST: $0.005        | First 1 GB free, then $0.09 per GB for data transferred to the internet  |
| **S3 Intelligent-Tiering**   | $0.023                 | No retrieval cost for frequent access      | PUT, COPY, POST, LIST: $0.005        | First 1 GB free, then $0.09 per GB for data transferred to the internet  |
| **S3 Standard-IA**           | $0.0125                | $0.01 per GB retrieval cost                | PUT, COPY, POST, LIST: $0.005        | First 1 GB free, then $0.09 per GB for data transferred to the internet  |
| **S3 One Zone-IA**           | $0.01                  | $0.01 per GB retrieval cost                | PUT, COPY, POST, LIST: $0.005        | First 1 GB free, then $0.09 per GB for data transferred to the internet  |
| **S3 Glacier**               | $0.004                 | $0.03 per GB retrieval (expedited)         | PUT, COPY, POST, LIST: $0.005        | First 1 GB free, then $0.09 per GB for data transferred to the internet  |
| **S3 Glacier Deep Archive**  | $0.00099               | $0.02 per GB retrieval (standard)          | PUT, COPY, POST, LIST: $0.005        | First 1 GB free, then $0.09 per GB for data transferred to the internet  |
| **S3 Outposts**              | Same as S3 Standard    | Varies (on-premises)                       | PUT, COPY, POST, LIST: $0.005        | Varies (on-premises)                        |


## Request Costs:
| **Request Type**               | **Cost per 1,000 Requests** | 
|--------------------------------|-----------------------------|
| **PUT, COPY, POST, LIST**      | $0.005 per 1,000 requests   |
| **GET and all other requests** | $0.0004 per 1,000 requests  |


## Data Transfer Costs:
| **Data Transfer**                     | **Cost**                                 | 
|---------------------------------------|------------------------------------------|
| **Data Transfer to Internet**         | First 1 GB/month free, then $0.09/GB     |
| **Data Transfer between AWS Regions** | $0.02/GB                                 |


## Calculating S3 Storage Costs:
To calculate your S3 storage costs, you can follow these steps:

**Step 1: Storage Costs**:<br/>
Example Calculation: If you're storing 100 GB in S3 Standard, the cost would be:
````console
100 GB * $0.023/GB = $2.30 per month
````

**Step 2: Retrieval Costs**:<br/>
Example Calculation: If you retrieve 10 GB from S3 Glacier using expedited retrieval:
````console
10 GB * $0.03/GB = $0.30 for retrieval
````

**Step 3: Request Costs:**:<br/>
Example Calculation:  If you make 5,000 PUT requests:
````console
5,000 PUT requests / 1,000 * $0.005 = $0.025
````

**Step 4: Data Transfer Costs::**:<br/>
Example Calculation:  If you transfer 5 GB to the internet:
````console
5 GB * $0.09 = $0.45 for transfer
````

### Total Monthly Cost Calculation:
For S3 Standard storage, retrieving from S3 Glacier, with PUT requests and data transfer:
````console
Storage Cost: 100 GB * $0.023 = $2.30
Retrieval Cost: 10 GB * $0.03 = $0.30
Request Cost: 5,000 PUT requests = $0.025
Data Transfer: 5 GB * $0.09 = $0.45
--------------------------------------
Total Monthly Cost: $2.30 + $0.30 + $0.025 + $0.45 = $3.075

````


## Notes:
- **Storage Costs**: Based on the storage class and amount of data stored in S3.
- **Retrieval Costs**: Applicable only for **S3 Glacier** and **S3 Glacier Deep Archive**, depending on retrieval type (expedited or standard).
- **Request Costs**: Charged based on PUT, COPY, POST, LIST, GET, and other S3 requests made to the bucket.
- **Data Transfer Costs**: Charged for data transferred out of S3 to the internet or other regions.

Use this table as a quick reference to estimate your S3 storage costs and plan your usage accordingly.
