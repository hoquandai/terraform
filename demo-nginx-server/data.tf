# get all available AZ's in VPC for current region
data "aws_availability_zones" "available" {
  state = "available"
}
