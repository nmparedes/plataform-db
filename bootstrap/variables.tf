variable "project_name" {
  description = "Project prefix used to name Terraform backend resources."
  type        = string
}

variable "aws_region" {
  description = "AWS region where the Terraform backend resources are created."
  type        = string
}

variable "state_bucket_name" {
  description = "Globally unique S3 bucket name for Terraform remote state."
  type        = string
}

variable "state_lock_table_name" {
  description = "DynamoDB table name used for Terraform state locking."
  type        = string
}

variable "state_key_prefix" {
  description = "Prefix consumed by later Terraform stacks when composing backend keys."
  type        = string
  default     = "platform-db"
}

variable "tags" {
  description = "Additional tags applied to bootstrap AWS resources."
  type        = map(string)
  default     = {}
}
