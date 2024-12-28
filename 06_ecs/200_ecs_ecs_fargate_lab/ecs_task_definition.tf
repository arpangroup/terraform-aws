resource "aws_ecs_task_definition" "TF_TASK_DEFINITION" {
  family                   = "nginx"
#   family                   = "springboot-app"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.iam-role.arn
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  container_definitions = jsondecode([
    {
      name      = "main-container"
      image     = ""
      cpu       = 1024
      memory    = 2048
      essential = true
      portMappings = [{
        containerPort = 80
        hostPort      = 80
      }]
    }
  ])

#   volume {
#     name = "service-storage"
#     host_path = "/ecs/service-storage"
#   }
}


##########################################
resource "aws_ecs_task_definition" "TF_TASK_DEFINITION_springboot_mysql_task" {
  family                   = "tf-springboot-mysql"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.iam-role.arn
  task_role_arn            = aws_iam_role.ecs-task.arn

  container_definitions = jsondecode([
    {
      name      = "springboot-app"
      image     = "your-dockerhub-username/springboot-app:latest"
      cpu       = 256
      memory    = 512
      portMappings = [{
        containerPort = 8080
        hostPort      = 8080
      }]
      environment = [
#         { name = "SPRING_DATASOURCE_URL", value = "jdbc:mysql://${aws_db_instance.mysql.endpoint}:3306/springbootdb" },
        { name = "SPRING_DATASOURCE_URL", value = "jdbc:mysql://mysql-container:3306/springbootdb:3306/springbootdb" },
        { name = "SPRING_DATASOURCE_USERNAME", value = "root" },
        { name = "SPRING_DATASOURCE_PASSWORD", value = "password123" }
      ],
      dependsOn = [{
        containerName = "mysql-container"
        condition     = "START"
      }]
    },
    {
      name      = "mysql-container"
      image     = "mysql:8.0"
      memory    = 512
      cpu       = 256
      environment = [
        { name = "MYSQL_ROOT_PASSWORD", value = "password123" },
        { name = "MYSQL_DATABASE", value = "springbootdb" }
      ],
      portMappings = [{
        containerPort = 3306
      }]
    }

  ])






data "aws_ecs_task_definition" "DATA_TD" {
  task_definition = aws_ecs_task_definition.TF_TASK_DEFINITION.family
}