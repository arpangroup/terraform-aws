resource "aws_ecs_task_definition" "TF_TASK_DEFINITION" {
  family                   = "nginx"
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

data "aws_ecs_task_definition" "DATA_TD" {
  task_definition = aws_ecs_task_definition.TF_TASK_DEFINITION.family
}