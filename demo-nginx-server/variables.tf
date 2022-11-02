variable "aws_ami" {
  type        = string
  description = "AWS Instance AMI"
  default     = "ami-08c40ec9ead489470" # ubuntu 22.04 64_x86 LTS
}

variable "instance_type" {
  description = "Type of AWS EC2 instance."
  default     = "t2.micro"
}

variable "public_key_path" {
  description = "Enter the path to the SSH Public Key to add to AWS."
  default     = "~/.ssh/id_ed25519.pub"
}

variable "private_key_path" {
  description = "Enter the path to the SSH Private Key to add to AWS."
  default     = "~/.ssh/id_ed25519"
}

variable "bootstrap_script_path" {
  description = "Enter the path to the bootstrap template."
  default     = "scripts/bootstrap.tpl"
}
