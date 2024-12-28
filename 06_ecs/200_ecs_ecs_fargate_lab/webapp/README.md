## Build the Docker Image
````bash
docker build -t hello-html-app .
docker images
````

## Run the Docker Container
````bash
docker run -d -p 8085:8080 hello-html-app
````

## Publish the Docker image to DockerHub
````bash
docker login
docker tag hello-html-app arpangroup/hello-html-app:v1.0
docker push arpangroup/hello-html-app:v1.0
````

## Publish the Docker image to ECR
- create repository
- **View push commands** on AWS console inside the above created repo