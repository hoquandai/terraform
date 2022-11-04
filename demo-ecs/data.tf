# get all available AZ's in VPC for current region
data "aws_availability_zones" "available" {
  state = "available"
}

data "template_file" "container_definitions" {
  template = file("templates/container_defination.tmpl")
  vars = {
    name        = var.name
    image       = var.image
    cpu         = var.cpu
    memory      = var.memory
    logs_group  = var.logs_group
    logs_region = "us-east-1"
  }
}

data "aws_iam_policy_document" "s3_ecr_access" {

}