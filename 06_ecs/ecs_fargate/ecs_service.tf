resource "aws_ecs_service" "TF_ECS-Service" {
  name             = "my-service"
  cluster          = aws_ecs_cluster.TF_ECS_CLUSTER.id
  launch_type      = "FARGATE" # [EC2, FARGATE, EXTERNAL]
  platform_version = "LATEST"  # Only for FARGATE launch type
  task_definition  = aws_ecs_task_definition.TF_TASK_DEFINITION.arn
  desired_count    = 2 # HOw many instance should be launched
  iam_role         = aws_iam_role.TF_IAM_ROLE.arn
  depends_on       = [aws_lb_listener.TF_ALB_LISTENER, aws_iam_role.TF_IAM_ROLE]

  scheduling_strategy                = "REPLICA" # [REPLICA, DAEMON]
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  #   force_new_deployment               = false

  #   ordered_placement_strategy {
  #     type  = "binpack"
  #     field = "cpu"
  #   }

  load_balancer {
    target_group_arn = aws_lb_target_group.TF_TG.arn
    container_name   = "main-container"
    container_port   = 80
  }

  network_configuration {
    assign_public_ip = true
    security_groups  = [aws_security_group.TF_SG.id]
    subnets          = [aws_subnet.TF_PUBLIC_SUBNET.id, aws_subnet.TF_PRIVATE_SUBNET.id]
  }

  #   placement_constraints {
  #     type       = "member01"
  #     expression = "attribute:ecs.availability-zone in [us-east-1a, us-east-1b]"
  #   }



}