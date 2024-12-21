# terraform apply -var-file="app.tfvars" -var="createdBy=e2esa"

/*locals {
  tags = {
    Project = var.project
    createdBy = var.createdBy
    CreatedOn = timestamp()
    Environment = terraform.workspace
  }
}*/