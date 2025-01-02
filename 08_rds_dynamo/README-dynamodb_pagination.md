# DynamoDB Pagination

````python
import boto3
from botocore.exceptions import BotoCoreError, ClientError

# Initialize clients
dynamodb = boto3.client('dynamodb')
sqs = boto3.client('sqs')

# Configuration
DYNAMODB_TABLE_NAME = 'YourDynamoDBTable'
SQS_QUEUE_URL = 'https://sqs.your-region.amazonaws.com/your-account-id/your-queue-name'
PARTITION_KEY_NAME = 'your-partition-key'

# Query DynamoDB and push to SQS
def query_dynamodb_and_push_to_sqs(partition_key_value):
    try:
        # DynamoDB query
        response = dynamodb.query(
            TableName=DYNAMODB_TABLE_NAME,
            KeyConditionExpression=f"{PARTITION_KEY_NAME} = :pkval",
            ExpressionAttributeValues={":pkval": {"S": partition_key_value}}
        )

        while True:
            # Push items to SQS
            for item in response.get('Items', []):
                message_body = {k: list(v.values())[0] for k, v in item.items()}  # Flatten DynamoDB response
                sqs.send_message(
                    QueueUrl=SQS_QUEUE_URL,
                    MessageBody=str(message_body)
                )

            # Check for more pages
            if 'LastEvaluatedKey' in response:
                response = dynamodb.query(
                    TableName=DYNAMODB_TABLE_NAME,
                    KeyConditionExpression=f"{PARTITION_KEY_NAME} = :pkval",
                    ExpressionAttributeValues={":pkval": {"S": partition_key_value}},
                    ExclusiveStartKey=response['LastEvaluatedKey']
                )
            else:
                break

        print("All items processed and sent to SQS.")

    except (BotoCoreError, ClientError) as error:
        print(f"An error occurred: {error}")

# Example usage
if __name__ == "__main__":
    query_dynamodb_and_push_to_sqs('example-partition-key')

````

---

## 1. Maven Dependencies
````xml
<dependencies>
    <dependency>
        <groupId>software.amazon.awssdk</groupId>
        <artifactId>dynamodb</artifactId>
        <version>2.20.0</version>
    </dependency>
    <dependency>
        <groupId>org.springframework.batch</groupId>
        <artifactId>spring-batch-core</artifactId>
        <version>5.1.0</version>
    </dependency>
    <dependency>
        <groupId>com.amazonaws</groupId>
        <artifactId>aws-java-sdk-dynamodb</artifactId>
        <version>1.12.568</version>
    </dependency>
</dependencies>
````

## 2. Define the DynamoDB Entity
````java
import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBHashKey;
import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBMapper;
import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBTable;

@DynamoDBTable(tableName = "YourTableName")
public class YourEntity {

    private String id;
    private String data;

    @DynamoDBHashKey(attributeName = "Id")
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getData() {
        return data;
    }

    public void setData(String data) {
        this.data = data;
    }
}

````

## 3. Spring Batch Configuration
````java
import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBMapper;
import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBScanExpression;
import org.springframework.batch.item.ItemReader;

import java.util.Iterator;

public class DynamoDBItemReader implements ItemReader<YourEntity> {

    private final DynamoDBMapper dynamoDBMapper;
    private final DynamoDBQueryExpression<YourEntity> queryExpression;
//    private final DynamoDBScanExpression scanExpression;
    private Iterator<YourEntity> iterator;
    private AttributeValue lastEvaluatedKey;

    public DynamoDBItemReader(DynamoDBMapper dynamoDBMapper, DynamoDBQueryExpression<YourEntity> queryExpression) {
        this.dynamoDBMapper = dynamoDBMapper;
        this.scanExpression = new DynamoDBScanExpression();
        this.queryExpression = queryExpression;
    }

    @Override
    public YourEntity read() {
       /* if (iterator == null) {
            iterator = dynamoDBMapper.scan(YourEntity.class, scanExpression).iterator();
        }

        return iterator.hasNext() ? iterator.next() : null;*/

        if (iterator == null || (!iterator.hasNext() && lastEvaluatedKey != null)) {
            fetchNextPage();
        }

        return (iterator != null && iterator.hasNext()) ? iterator.next() : null;
    }

    private void fetchNextPage() {
        if (lastEvaluatedKey != null) {
            queryExpression.setExclusiveStartKey(lastEvaluatedKey);
        }

        List<YourEntity> items = dynamoDBMapper.query(YourEntity.class, queryExpression);
        if (!items.isEmpty()) {
            iterator = items.iterator();
        }

        // Update the last evaluated key for pagination
        lastEvaluatedKey = dynamoDBMapper.getLastEvaluatedKey();
    }
}

````

## Processor
````java
import org.springframework.batch.item.ItemProcessor;

public class DynamoDBProcessor implements ItemProcessor<YourEntity, ProcessedEntity> {

    @Override
    public ProcessedEntity process(YourEntity item) {
        // Transform YourEntity to ProcessedEntity
        ProcessedEntity processed = new ProcessedEntity();
        processed.setProcessedData("Processed: " + item.getData());
        return processed;
    }
}

````

## Job Configuration
````java
import org.springframework.batch.core.Job;
import org.springframework.batch.core.Step;
import org.springframework.batch.core.configuration.annotation.EnableBatchProcessing;
import org.springframework.batch.core.configuration.annotation.JobBuilderFactory;
import org.springframework.batch.core.configuration.annotation.StepBuilderFactory;
import org.springframework.batch.item.ItemProcessor;
import org.springframework.batch.item.ItemReader;
import org.springframework.batch.item.ItemWriter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@EnableBatchProcessing
public class BatchConfig {

    @Bean
    public ItemReader<YourEntity> reader(DynamoDBMapper dynamoDBMapper) {
//        return new DynamoDBItemReader(dynamoDBMapper);
        DynamoDBQueryExpression<YourEntity> queryExpression = buildQueryExpression("partition-key-value");
        return new DynamoDBItemReader(dynamoDBMapper, queryExpression);
    }

    @Bean
    public ItemProcessor<YourEntity, ProcessedEntity> processor() {
        return new DynamoDBProcessor();
    }

    @Bean
    public ItemWriter<ProcessedEntity> writer() {
        return items -> {
            for (ProcessedEntity item : items) {
                System.out.println("Writing item: " + item.getProcessedData());
            }
        };
    }

    @Bean
    public Step step(StepBuilderFactory stepBuilderFactory, ItemReader<YourEntity> reader,
                     ItemProcessor<YourEntity, ProcessedEntity> processor, ItemWriter<ProcessedEntity> writer) {
        return stepBuilderFactory.get("step")
                .<YourEntity, ProcessedEntity>chunk(10)
                .reader(reader)
                .processor(processor)
                .writer(writer)
                .build();
    }

    @Bean
    public Job job(JobBuilderFactory jobBuilderFactory, Step step) {
        return jobBuilderFactory.get("job")
                .start(step)
                .build();
    }

    public DynamoDBQueryExpression<YourEntity> buildQueryExpression(String partitionKeyValue) {
        YourEntity hashKeyEntity = new YourEntity();
        hashKeyEntity.setId(partitionKeyValue); // Set partition key

        return new DynamoDBQueryExpression<YourEntity>()
                .withHashKeyValues(hashKeyEntity)
                .withConsistentRead(false); // Use consistent reads if required
    }
}

````