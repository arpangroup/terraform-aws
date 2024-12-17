resource "aws_ecs_cluster" "TF_ECS_CLUSTER" {
  name = "my-tf-cluster"

  tags = {
    Name = "TF_ECS_CLUSTER"
  }
}