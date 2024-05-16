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

variable "boundary_cluster_url" {
  description = "Boundary cluster URL"
  type        = string
}

variable "boundary_worker_tags" {
  description = "Tags to add to the Boundary worker"
  type        = map(string)
}

variable "initial_upstreams" {
  description = "Initial upstream Boundary worker (leave blank for ingress workers)"
  type        = list(string)
  nullable    = true
}

variable "is_ingress_worker" {
  description = "Is this an ingress worker with HCP Boundary as upstream?"
  type        = bool
}

variable "worker_name" {
  description = "Name of the Boundary worker"
  type        = string
}
