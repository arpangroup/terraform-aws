# AWS CloudWatch (Monitoring + Alerting + Reporting + Logging )
- [Metrics](README-metrics.md) (Default + [Custom Metrics](README-metrics_custom.md))
- [Logs](README-logs.md) (LogGroup + LogStream + LogInsights)
- Alarms
- X-Ray Traces
- Events
- Insight
- Cost Optimization using Lambda





## Other Metrics
- For `AWS/EC2`:
  - `CPUUtilization`: Average CPU usage.
  - `DiskReadBytes` / `DiskWriteBytes`: Disk I/O in bytes.
  -  `NetworkIn` / `NetworkOut`: Network traffic in and out.
- For `AWS/EC2`:
  - `RequestCount`: Number of requests.
  - `HTTPCode_ELB_5XX`: Count of 5XX errors.
  - `Latency`: Time taken for requests.
- For `AWS/RDS`:
  - `CPUUtilization`: CPU usage.
  - `DatabaseConnections`: Active database connections.
  - `FreeStorageSpace`: Available storage space.
- For `AWS/S3`:
  - `BucketSizeBytes`: Total size of objects in the bucket.
  - `NumberOfObjects`: Count of objects in the bucket.
- For `AWS/Lambda`:
  - `Invocations`: Number of function invocations.
  - `D