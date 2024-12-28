# EC2 Spot Instances Vs Spot Fleet
EC2 Spot Instances allow you to use unused AWS compute capacity at significantly reduced costs (up to 90% cheaper than On-Demand prices). However, Spot Instances can be interrupted by AWS if the capacity is needed elsewhere, making them suitable for workloads that are `fault-tolerant` and `flexible`.

![img.png](../../diagrams/ec2_spot_instance.png)

## EC2 Spot Instance
A Spot Instance is a single instance type that you request at a variable price. It is best suited for workloads that can handle interruptions and do not require a large scale or diverse set of instance types.

### Key Characteristics:
1. **Single Instance Type**: You specify the instance type you want (e.g., t3.micro).
2. **Manual Scaling**: You have to manually manage the scaling and additional requests.
3. **Use Case**: Ideal for ad hoc, small-scale workloads, or when a specific instance type is required.
4. **Management**: Managed individually like an On-Demand instance but at a lower cost.


## Spot Fleet
A Spot Fleet is a collection of Spot Instances, with the option to mix On-Demand Instances, that you can launch and manage as a group. It provides more flexibility and automation for large-scale workloads.

### Key Characteristics:
1. **Diversified Instance Types**: Spot Fleet can use multiple instance types and availability zones for better cost optimization and higher availability.
2. **Automated Scaling**: Target capacity is automatically managed based on your specified requirements.
3. **Allocation Strategy**:
   - **Lowest Price**: Selects the cheapest instances available.
   - **Capacity Optimized**: Focuses on pools with spare capacity to reduce interruptions.
4. **Combination of Spot and On-Demand**: You can define a mix of Spot and On-Demand instances in your fleet for guaranteed capacity.
5. **Use Case**: Suitable for large-scale, distributed, and fault-tolerant workloads such as big data processing, containerized applications, or CI/CD pipelines.


# EC2 Spot Instance vs Spot Fleet

| **Feature**            | **Spot Instance**             | **Spot Fleet**                            |
|------------------------|-------------------------------|-------------------------------------------|
| **Scale**              | Single instance               | Multiple instances across instance types  |
| **Flexibility**        | Limited to one instance type  | Flexible across types and availability zones |
| **Management**         | Manual                        | Automated                                 |
| **Use Case**           | Small workloads               | Large-scale, distributed workloads        |
| **Pricing Strategy**   | Fixed to a single bid         | Optimized across multiple pools           |

Choose **Spot Instances** for simplicity and **Spot Fleets** for large-scale, fault-tolerant, and cost-optimized environments.


## Using `aws_instance` for Spot Instances
You can configure a Spot Instance using the `aws_instance` resource by specifying the `spot_price` argument:
````hcl
# Spot Instance configuration
resource "aws_instance" "spot_instance" {
  ami                         = "ami-0b2f6494ff0b07a0e" # Replace with your desired AMI ID (e.g., Amazon Linux or Windows)
  instance_type               = "t2.micro" # Choose your instance type
  key_name                    = "my-key-pair" # Replace with your SSH key pair name
  security_groups             = [aws_security_group.ssh_sg.name]

  # Spot Instance configuration
  spot_price                  = "0.05" # Specify the maximum price you're willing to pay per hour (e.g., 0.05 USD)
  instance_interruption_behaviour = "terminate" # Action if the instance is interrupted
  wait_for_capacity_timeout    = "0"  # Don't wait for spot instance capacity

  # Tags
  tags = {
    Name = "Spot-Instance"
  }
}

output "spot_instance_public_ip" {
  value = aws_instance.spot_instance.public_ip
}
````
- **Why Use aws_instance?** Simplified configuration for basic use cases.


## Using `aws_spot_instance_request`
To create an EC2 Spot Fleet using Terraform, you can define a `aws_spot_fleet_request` resource. <br/>Below is an example configuration:
````hcl

resource "aws_spot_fleet_request" "example" {
   iam_fleet_role           = "arn:aws:iam::123456789012:role/aws-ec2-spot-fleet-tagging-role"
   spot_price               = "0.03" # Maximum price per instance-hour
   target_capacity          = 5
   allocation_strategy      = "lowestPrice"
   terminate_instances_with_expiration = true
   valid_until              = "2024-12-31T23:59:59Z"

   launch_specification {
      instance_type           = "t3.micro"
      ami                     = "ami-0c55b159cbfafe1f0" # Replace with a valid AMI ID
      key_name                = "my-key"
      subnet_id               = "subnet-0bb1c79de3EXAMPLE"
      iam_instance_profile {
         name = aws_iam_instance_profile.spot_instance_profile.name
      }
      iam_instance_profile = "......"
      vpc_security_group_ids = []

      root_block_device {
         volume_size = 20
         volume_type = "gp2"
      }

      tags = {
         Name = "Spot-Fleet-Instance"
      }
   }
}

resource "aws_iam_instance_profile" "spot_instance_profile" {
  name = "spot-instance-profile"

  role {
    name = "ec2-spot-role"
  }
}
````
- **IAM Role**: Ensure the `aws-ec2-spot-fleet-tagging-role` is correctly set up for managing the Spot Fleet.
- **Pricing**: Adjust `spot_price` according to your budget and region pricing.
- **Lifecycle Management**: Spot Fleets can terminate automatically based on expiration or capacity reduction.



## Why we are using combination of Spot Instances along with On-Demand EC2?
- To provide maximum availability and 0 downtime of our services we can combine the spot instances with On-Demand Ec2 instances, so that our service never interrupted.


## Real-World Use Cases for Spot Instances
1. Batch Processing:
    - **Scenario:** Large-scale data processing tasks like rendering, video transcoding, or ETL pipelines that can tolerate interruptions.
    - **Example:** Processing a backlog of videos for a streaming service using Spot Instances to keep costs low.
2. CI/CD Pipelines (Build and Test)
    - **Scenario:** Running automated build, test, and deployment pipelines that involve short-lived compute tasks.
    - **Example:** Using Spot Instances to perform unit tests, integration tests, or container builds in Jenkins or GitLab.
3. Big Data and Analytics
    - **Scenario:** Running distributed processing frameworks like Apache Spark, Hadoop, or EMR for analytics workloads.
    - **Example:** Spot Instances can be used as worker nodes to process log files or analyze large datasets.
4. Machine Learning Training
5. Rendering and Simulations
6. Web Applications with Auto Scaling
   - **Scenario:** Low-priority, stateless workloads where you combine Spot Instances with On-Demand instances in an Auto Scaling Group (ASG).
   - **Example:** Running front-end servers for a seasonal or low-criticality application.



## Videos:
- [Master EC2 Spot Instances: Ultimate Guide to Massive Savings - Part 21](https://www.youtube.com/watch?v=b6oPVrDvV8E&list=PL7iMyoQPMtAPVSnMZOpptxGoPqwK1piC6&index=20)
- 
