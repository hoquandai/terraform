variable "app_name" {
  description = "The name of the application."
  type        = string
  default     = "sns"
}

variable "org_name" {
  description = "The name of the organization."
  type        = string
  default     = "daiho"
}

variable "env" {
  description = "The environment to run the application."
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Tag names for OpenSearch service."
  default = {
    name = "OpenSearch"
  }
}

variable "allow_security_groups" {
  description = "Allowed SecurityGroup IDs."
  type        = list(string)
  default     = []
}

variable "subnet_db_ids" {
  description = "Common private subnets for DB connections."
  type        = list(string)
  default     = []
}

# variable vpc_id {
#   description = "Main VPC ID."
#   type = string
# }

variable "az_ids" {
  description = "Availability zone IDS for data nodes."
  type        = list(string)
  default = [
    "us-east-1a"
  ]
}

variable "ebs_volume_size" {
  description = "Size of EBS volumes attached to data nodes (in GiB)."
  type        = number
  default     = 10
}

variable "ebs_volume_type" {
  description = "Type of EBS volumes attached to data nodes."
  type        = string
  default     = "gp2"
}

variable "dedicated_master_count" {
  description = "Number of dedicated main nodes in the cluster."
  type        = number
  default     = 0
}

variable "dedicated_master_type" {
  description = "Instance type of the dedicated main nodes in the cluster"
  type        = string
  default     = "m5.large.search"
}

variable "engine_version" {
  description = "OpenSearch engine version."
  type        = string
  default     = "OpenSearch_1.3"
}

variable "instance_type" {
  description = "OpenSearch instance type."
  type        = string
  default     = "t3.medium.search"
}

variable "instance_count" {
  description = "OpenSearch instance count."
  type        = number
  default     = 1
}

variable "master_user_name" {
  description = "OpenSearch Main user's username."
  type        = string
  default     = "master"
}

variable "master_user_password" {
  description = "OpenSearch Main user's password."
  type        = string
  default     = "master"
}
