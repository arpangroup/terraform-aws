# TargetGroup:
An `AWS Target Group` is a component of `ELB` that routes incoming traffic to specific registered targets, such as:
- Amazon EC2 instances
- IP addresses
- AWS Lambda functions
- Containers (e.g., tasks in Amazon ECS or Kubernetes)

## Key Concepts of Target Groups:

### 1. Associated with Load Balancers
Target groups are linked to load balancers (e.g., Application Load Balancers, Network Load Balancers, or Gateway Load Balancers) to distribute incoming traffic.

### 2. Targets
Targets are resources that receive traffic routed by the load balancer. Examples:
- EC2 instances (by instance ID)
- Specific IP addresses
- AWS Lambda functions (for ALBs)
- ECS services or Fargate tasks


### 3. Target Type:
When creating a target group, you define the target type, which determines how traffic is routed:
- **Instance:** Routes to an EC2 instance.
- **IP:** Routes to a specific private IPv4 or IPv6 address.
- **Lambda:** Routes to a Lambda function.

### 4. Protocol and Port
Target groups allow you to define the protocol (HTTP, HTTPS, TCP, TLS, etc.) and port that the load balancer should use to route traffic to the targets.


### 5. Health Checks:
Each target group has health checks to monitor the status of registered targets. The load balancer only routes traffic to healthy targets. You can configure:
- Protocol (HTTP, HTTPS, TCP, etc.)
- Path (e.g., `/health`)
- Health check intervals, timeout, and thresholds.

### 6. Listener Rules
Target groups work in combination with **listeners** on the load balancer. Listeners route traffic to specific target groups based on rules (e.g., path-based routing, host-based routing, or default routing).

## Use Cases of Target Groups:
### 1. Web Applications:
You can use **path-based** routing with Application Load Balancers to direct traffic to different target groups based on URL paths. For example:
- `/api/*` → API servers (target group 1)
- `/static/*` → Static content servers (target group 2)







