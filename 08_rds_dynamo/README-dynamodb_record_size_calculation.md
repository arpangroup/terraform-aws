# DynamoDB Record Size Calculation

This document explains how to calculate the size of a DynamoDB record with an example, formatted into a table.

---

## General Size Formula
To calculate the size of a DynamoDB record:

- **Partition Key & Sort Key (if used):**
   - Size = Length of string (in bytes) + 1 byte (for data type).
- **Other Attributes:**
   - **String**: Size = Length of string (in bytes) + 1 byte.
   - **Number**: Size = Variable, depends on the number's encoding.
   - **Boolean**: Size = 1 byte.
   - **Binary**: Size = Length of binary (in bytes) + 1 byte.
   - **List/Set/Map**: Size = Sum of elements + overhead.

---
## Example Table

| UserId <br/> (String)<br/> (PartitionKey) | OrderId <br/> (String) <br/>(SortKey) | Name <br/> (String) |Age<br/> (Number) | Items  <br/> (List)             | Metadata  <br/> (Map)                                   |
|-------------------------------------------|---------------------------------------|---------------------|---|-----------------------------|----------------------------------------------|
| 123456                                    | ORD-001                               | John Doe            |30 | ["Item1", "Item2", "Item3"] | {"isPrime": true, "category": "Electronics"} |


## Size Calculation

| Attribute       | Details                                                                                                                                                             | Size (Bytes) |
|-----------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------|
| **Partition Key** | "123456" (6 bytes) + 1 byte (data type overhead)                                                                                                                    | 7            |
| **Sort Key**     | "ORD-001" (7 bytes) + 1 byte (data type overhead)                                                                                                                   | 8            |
| **Name**         | "John Doe" (8 bytes) + 1 byte (data type overhead)                                                                                                                  | 9            |
| **Age**          | 30 (approx. 2 bytes) + 1 byte (data type overhead)                                                                                                                  | 3            |
| **Items**        | ["Item1", "Item2", "Item3"]: <li>"Item1": 5 bytes</li><li>"Item2": 5 bytes</li><li>"Item3": 5 bytes</li><li>List overhead: 3 bytes</li>                             | 18           |
| **Metadata**     | {"isPrime": true, "category": "Electronics"}: <li>"isPrime": 7 bytes</li><li>true: 1 byte</li><li>"category": 8 bytes</li><li>"Electronics": 10 bytes</li><li>Map overhead: 3 bytes   </li> | 29           |

---

## Total Record Size

Summing up all components:  
**7 (UserId) + 8 (OrderId) + 9 (Name) + 3 (Age) + 18 (Items) + 29 (Metadata) = 74 bytes**.

---

## Key Notes

1. DynamoDB rounds the total size to the nearest multiple of **1KB** for billing purposes.
2. The maximum item size in DynamoDB is **400 KB**, including attribute names and values.
