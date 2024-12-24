
# 1. Amazon CloudWatch Metrics
CloudWatch metrics are numerical data points that represent the performance or usage of AWS resources over time.

## 1.1. Key Components of CloudWatch Metrics:
1. **Namespace**: A container for metrics related to a specific AWS service or custom application.
    - `AWS/EC2`: Metrics for EC2 instances.
    - `AWS/Lambda`: Metrics for Lambda functions.
    - Custom metrics can have user-defined namespaces.
2. **Metrices**: Specific data points tracked in a namespace.
    - **For EC2**: `CPUUtilization`, `DiskReadBytes`/`DiskWriteBytes`, `NetworkIn`/`NetworkOut`
    - **For Lambda**: `Invocations`, `Duration`, `Throttles`
    - **For RDS**: `DatabaseConnections`, `FreeStorageSpace`.
3. **Dimensions**: Key-value pairs that identify a specific metric within a namespace.
    - **Example**: EC2 instance ID (`InstanceId`). Auto Scaling group name (`AutoScalingGroupName`).
4. **Statistics**: Aggregations of raw data points over a period.
    - `Average`: Average of all data points.
    - `Sum`: Total of all data points.
    - `Minimum` / `Maximum`: Smallest or largest value.
5. **Time Period**: The interval for aggregating data points (e.g., 1 minute, 5 minutes).



## 1.2. Common CloudWatch Metrics by Service
1. EC2
    - `CPUUtilization`: Percentage of allocated EC2 CPU in use.
    - `DiskReadBytes` / `DiskWriteBytes`: Amount of data read/written to disk.
    - `NetworkIn` / `NetworkOut`: Network traffic in/out in bytes.
2. Lambda
    - `Invocations`: Number of function calls
    - `Duration`: Execution time of the function
    - `Throttles`: Number of requests throttled due to hitting concurrency limits.
3. Auto Scaling
    - `GroupDesiredCapacity`: Desired number of instances in the ASG.
    - `GroupInServiceInstances`: Instances currently healthy and serving traffic.
    - `GroupTerminatingInstances`: Instances being terminated.
4. ELB
    - `RequestCount`: Number of requests processed by the load balancer.
    - `HTTPCode_ELB_4XX` / `HTTPCode_ELB_5XX`: Counts of 4xx or 5xx responses.
    - `Latency`: Time taken for a request to be processed.
5. RDS
    - `CPUUtilization`: Percentage of CPU used.
    - `DatabaseConnections`: Active database connections.
    - `FreeStorageSpace`: Available storage space.

## 1.3. Custom Metrics
You can define custom metrics for your applications or workloads by pushing them to CloudWatch. For example:
- Tracking the number of user logins.
- Monitoring application-specific KPIs.
### Example (Using AWS CLI):
````bash
aws cloudwatch put-metric-data --metric-name UserLogins --namespace Custom/Applications --value 10 --dimensions Application=WebApp
````

## 1.4. Using Metrics
1. **Dashboards**: Visualize metrics in CloudWatch Dashboards for real-time monitoring.
2. **Alarms**: Set up alarms to trigger actions (e.g., scaling up/down) when a metric breaches a threshold.
3. **Logs Insights**: Query logs to derive metrics using CloudWatch Logs Insights.
4. **Export**: Export metrics to external monitoring tools (e.g., Prometheus, Datadog).
