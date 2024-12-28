
# Comparison of S3 Storage Classes

| Storage Class               | Durability           | Availability           | Retrieval Time            | Cost         | UseCase                                                                                                                                                                                   |
|-----------------------------|----------------------|------------------------|---------------------------|--------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **S3 Standard**             | 99.999999999%        | 99.99%                 | Instant                   | High         | Websites, mobile app                                                                                                                                                                      |
| **S3 Intelligent-Tiering**  | 99.999999999%        | 99.9%                  | Instant                   | Medium       | archives that are occasionally accessed.                                                                                                                                                  |
| **S3 Standard-IA** <br/>(Infrequent Access)  | 99.999999999%        | 99.9%                  | Instant                   | Medium       | Backup files, disaster recovery data, and infrequently accessed data that is still needed quickly when accessed.                                                                          |
| **S3 One Zone-IA**          | 99.999999999%        | 99.5%                  | Instant                   | Low          | Infrequently accessed data that does not require multiple availability zones for resilience. <br/><b>Example:</b>Data that can be recreated or is non-critical (e.g., temporary backups). |
| **S3 Glacier**              | 99.999999999%        | 99.99%                 | Minutes to hours          | Very Low     | Long-term archival storage for compliance, backup, and digital preservation.                                                                                                              |
| **S3 Glacier Deep Archive** | 99.999999999%        | 99.9%                  | Hours to days             | Extremely Low| Long-term archival storage                                                                                                                                                                |
| **S3 Outposts**             | Same as S3 Standard  | Varies (on-premises)   | Instant                   | Varies       | Data storage on AWS Outposts, which are fully managed, on-premises infrastructure extensions. <br/><b>Example:</b>Applications with strict data residency requirements                                                                        |

## Key Takeaways:
- **S3 Standard** is best for frequently accessed data.
- **S3 Intelligent-Tiering** automatically moves data between frequent and infrequent access tiers.
- **S3 Glacier** and **S3 Glacier Deep Archive** are suitable for long-term archival storage with different access times and cost structures.
- **S3 One Zone-IA** is useful for data that can tolerate being stored in a single availability zone.

