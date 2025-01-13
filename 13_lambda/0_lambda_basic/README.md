# AWS Lambda function with Java
### Prerequisites:
1. **AWS SDK for Java**: Ensure you have the AWS SDK for Java installed.
2. **Maven**: Use Maven to manage dependencies and build the project.
3. **AWS Lambda Java Core Library**: Add the necessary dependencies for AWS Lambda.

---

## Step 1: Create a Maven Project
Create a Maven project and add the following dependencies to your `pom.xml` file:
````xml
<dependencies>
    <!-- AWS Lambda Java Core -->
    <dependency>
        <groupId>com.amazonaws</groupId>
        <artifactId>aws-lambda-java-core</artifactId>
        <version>1.2.2</version>
    </dependency>

    <!-- AWS Lambda Java Events (optional, for event handling) -->
    <dependency>
        <groupId>com.amazonaws</groupId>
        <artifactId>aws-lambda-java-events</artifactId>
        <version>3.11.1</version>
    </dependency>

    <!-- Jackson for JSON parsing -->
    <dependency>
        <groupId>com.fasterxml.jackson.core</groupId>
        <artifactId>jackson-databind</artifactId>
        <version>2.13.3</version>
    </dependency>
</dependencies>

<build>
    <plugins>
        <!-- Maven Shade Plugin for packaging -->
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-shade-plugin</artifactId>
            <version>3.3.0</version>
            <configuration>
                <createDependencyReducedPom>false</createDependencyReducedPom>
            </configuration>
            <executions>
                <execution>
                    <phase>package</phase>
                    <goals>
                        <goal>shade</goal>
                    </goals>
                </execution>
            </executions>
        </plugin>
    </plugins>
</build>
````

## Step 2: Write the Lambda Function
````java
package com.example;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.util.Map;

public class HelloLambda implements RequestHandler<Map<String, String>, String> {

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public String handleRequest(Map<String, String> input, Context context) {
        // Log the input event
        context.getLogger().log("Input: " + input);

        // Extract the "name" from the input event
        String name = input.getOrDefault("name", "World");

        // Create a response
        String response = "Hello, " + name + "!";

        // Log the response
        context.getLogger().log("Response: " + response);

        return response;
    }
}
````

## Step 3: Package the Lambda Function
````bash
mvn clean package
````

## Step 4: Deploy the Lambda Function
1. Go to the AWS Management Console.
2. Navigate to AWS Lambda.
3. Click Create Function.
4. Choose Author from scratch.
5. Provide a name for your function, e.g., `HelloLambda`.
6. Select Java 17 (or the Java runtime version you used).
7. Upload the JAR file generated in Step 3.
8. Set the Handler to `com.example.HelloLambda::handleRequest`.

## Step 5: Test the Lambda Function
1. In the AWS Lambda console, click Test.
2. Create a new test event with the following JSON input:
    ````json
    {
      "name": "Alice"
    }
    ````
3. Run the test. You should see the output:
    ````
    "Hello, Alice!"
    ````