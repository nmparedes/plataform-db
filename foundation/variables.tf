variable "project_name" {
  description = "Project prefix used for shared AWS foundation resources."
  type        = string
}

variable "environment" {
  description = "Environment name such as dev, staging or prod."
  type        = string
}

variable "aws_region" {
  description = "AWS region where the shared AWS foundation resources are created."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block assigned to the shared VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zone_suffixes" {
  description = "Availability zone suffixes used to create paired subnets in the selected region."
  type        = list(string)
  default     = ["a", "b"]
}

variable "tags" {
  description = "Additional tags applied to shared AWS foundation resources."
  type        = map(string)
  default     = {}
}
