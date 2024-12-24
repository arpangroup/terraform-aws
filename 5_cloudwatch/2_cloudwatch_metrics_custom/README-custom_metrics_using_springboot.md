# CloudWatch Custom Metrics Using SpringBoot

## Step1: Set Up AWS SDK for CloudWatch
````xml
<dependency>
    <groupId>software.amazon.awssdk</groupId>
    <artifactId>cloudwatch</artifactId>
    <version>2.20.89</version>
</dependency>
````

## Step2: Configure AWS Credentials
Set up your AWS credentials so the application can authenticate with AWS. Use either:
- Environment variables: `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`
- **AWS CLI configured profile**
- **IAM role** (if deployed on AWS services like EC2 or Lambda)

## Step3: Write the Code to Publish Metrics
````java
import org.springframework.stereotype.Service;
import software.amazon.awssdk.services.cloudwatch.CloudWatchClient;
import software.amazon.awssdk.services.cloudwatch.model.MetricDatum;
import software.amazon.awssdk.services.cloudwatch.model.PutMetricDataRequest;
import software.amazon.awssdk.services.cloudwatch.model.StandardUnit;

import java.time.Instant;

@Service
public class CloudWatchMetricsService {

    private final CloudWatchClient cloudWatchClient;

    public CloudWatchMetricsService() {
        this.cloudWatchClient = CloudWatchClient.create(); // Automatically uses configured credentials
    }

    public void publishCheckoutFailureMetric(int failureCount) {
        MetricDatum metricDatum = MetricDatum.builder()
                .metricName("CheckoutFailures")
                .unit(StandardUnit.COUNT)
                .value((double) failureCount)
                .timestamp(Instant.now())
                .build();

        PutMetricDataRequest request = PutMetricDataRequest.builder()
                .namespace("MyECommerceApp") // Custom namespace for grouping metrics
                .metricData(metricDatum)
                .build();

        cloudWatchClient.putMetricData(request);
    }
}
````

## Step4: Use the Service in Your Application
Inject and use the `CloudWatchMetricsService` in your application logic. For example, track failed checkouts in the checkout controller:
````java
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class CheckoutController {

    @Autowired
    private CloudWatchMetricsService cloudWatchMetricsService;

    @PostMapping("/checkout")
    public String checkout() {
        try {
            // Checkout logic here...
            return "Checkout successful!";
        } catch (Exception e) {
            cloudWatchMetricsService.publishCheckoutFailureMetric(1);
            return "Checkout failed!";
        }
    }
}
````

## Step5: Verify the Metric in AWS CloudWatch
1. Open the CloudWatch Console.
2. Go to **Metrics > All Metrics > Custom Namespaces**.
3. Select the `MyECommerceApp` namespace to view your custom metric.

## Optional: Automate Metric Collection
For recurring metrics (e.g., CPU usage, error rate), you can schedule the `publishCheckoutFailureMetric` method using Spring Boot's `@Scheduled` annotation:
````java
@Scheduled(fixedRate = 60000) // Run every 60 seconds
public void reportMetrics() {
    int failureCount = getFailureCount(); // Replace with actual logic to fetch failure count
    publishCheckoutFailureMetric(failureCount);
}
````