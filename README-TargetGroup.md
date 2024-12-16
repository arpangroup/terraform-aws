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


## Why we need target group> why alb cant forward to the instance or target?
Target groups in AWS are used to abstract and manage the backend resources that a load balancer routes traffic to. While it may seem simpler for the ALB to forward requests directly to instances or targets, **target groups provide several key benefits and flexibility** that make them essential in modern load balancer architecture.
### Why We Need Target Groups
1. **Decoupling of Targets** from the Load Balancer
2. **Support for Different Types of Targets** like EC2 instances, IP addresses for service running outside of AWS, Lambda Function, ECS tasks 
3. **Health Checks:** Each target group has its own **health check configuration**.
4. **Dynamic Scaling:** In auto-scaling scenarios, new instances or tasks can automatically register with the target group. This simplifies scaling without needing to update the ALB configuration.
5. **Multiple Listeners and Routing Rules**
6. **Support for Weighted Routing:** Target groups allow **weighted routing**, where traffic can be distributed proportionally between multiple target groups. This is useful for canary deployments or gradual rollouts.
7. **Reusability Across Load Balancers:** The same target group can be used by multiple ALBs or listeners, reducing duplication and simplifying management.



## Why target group need port and protocol?
### 1. Port: Specifies Where to Send Traffic on the Target

**Why It's Needed:**

- Each target (e.g., an EC2 instance or ECS task) can host multiple applications or services, each running on different ports.
- The port in the target group tells the load balancer which port on the target to send incoming traffic to.
- Example: If your application runs on port `8080` on the EC2 instances, the target group needs to specify `8080` to forward requests to that application.

**Flexibility:**
- A single instance can belong to multiple target groups, each configured to forward traffic to a different port for different services (e.g., one target group for port `8080` and another for port `9090`).


### 2. Protocol: Defines How the Traffic Is Communicated
- The protocol specifies the communication standard used between the load balancer and the targets (e.g., HTTP, HTTPS, TCP, UDP).




