variable "aws_instance_associate_public_ip_address" {
  description = "Associate a public IP to the EC2 instance?"
  type        = bool
}

variable "aws_instance_profile_name" {
  description = "Name of the instance profile to attach to the EC2 instance"
  type        = string
}

variable "aws_instance_tags" {
  description = "Map of tags to add to the AWS EC2 instance"
  type        = map(string)

  validation {
    condition     = lookup(var.aws_instance_tags, "Name", "error") != "error"
    error_message = "The 'Name' tag is required"
  }
}

variable "aws_instance_type" {
  description = "Instance type (size)"
  type        = string
}

variable "aws_region" {
  description = "In which AWS region to create the worker"
  type        = string
}

variable "aws_security_group_id" {
  description = "VPC security group ID"
  type        = string
}

variable "aws_subnet" {
  description = "VPC subnet where to create the worker"
  type = object({
    id                = string
    availability_zone = string
  })
}

variable "boundary_worker_config" {
  description = "A HCL file for the worker configuration"
  type        = string
}

# TODO delete
variable "aws_ec2_key_name" {
  description = "Instance key name for SSH access"
  type        = string
}
