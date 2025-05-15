variable "aws_region" {
  description = "AWS region where resources will be provisioned"
  type        = string
  default     = "us-east-1"
}

# variable "ami_id" {
#   description = "AMI ID for the EC2 instance"
#   type        = string
#   default     = "ami-085f9c64a9b75eed5"
# }

variable "key_name" {
  description = "The name of the key pair to use for SSH access"
  type        = string
  default     = "aws-key" # Replace with your key pair name
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "tags" {
  description = "Tags to assign to the EC2 instance"
  type        = map(string)
  default = {
    Name = "Automated-Instance-Terraform"
  }
}

variable "my_enviroment" {
  description = "The environment for the EC2 instance"
  type        = string
  default     = "dev"
}

variable "ec2_default_root_storage_size" {
  description = "The size of the root volume in GB"
  type        = number
  default     = 8
}

variable "ec2_default_root_storage_type" {
  description = "The type of the root volume"
  type        = string
  default     = "gp3"

}

variable "instance_count" {
  description = "The number of EC2 instances to create"
  type        = number
  default     = 1
}



