variable "project_name" {
  description = "Project prefix used for managed database resources."
  type        = string
}

variable "environment" {
  description = "Environment name such as dev, staging or prod."
  type        = string
}

variable "aws_region" {
  description = "AWS region for RDS and Secrets Manager resources."
  type        = string
}

variable "vpc_id" {
  description = "Fallback VPC where RDS security groups are created when foundation remote state is not configured."
  type        = string
  default     = null
}

variable "private_subnet_ids" {
  description = "Fallback private subnet IDs for managed MySQL databases when foundation remote state is not configured."
  type        = list(string)
  default     = null
}

variable "foundation_state_bucket" {
  description = "S3 bucket that stores the Terraform state for the shared AWS foundation."
  type        = string
  default     = null
}

variable "foundation_state_key" {
  description = "S3 object key for the shared AWS foundation Terraform state file."
  type        = string
  default     = null
}

variable "foundation_state_region" {
  description = "AWS region where the shared AWS foundation Terraform state bucket exists."
  type        = string
  default     = null
}

variable "allowed_mysql_cidr_blocks" {
  description = "CIDR blocks allowed to reach MySQL. Keep empty until network ownership is explicit."
  type        = list(string)
  default     = []
}

variable "mysql_service_databases" {
  description = "Service-owned MySQL database definitions."
  type = map(object({
    service_name  = string
    database_name = string
  }))
  default = {
    customer = {
      service_name  = "customer-service"
      database_name = "customer_service"
    }
    os = {
      service_name  = "os-service"
      database_name = "os_service"
    }
    workshop = {
      service_name  = "workshop-service"
      database_name = "workshop_service"
    }
  }
}

variable "mysql_engine_version" {
  description = "Amazon RDS MySQL engine version."
  type        = string
  default     = "8.0"
}

variable "mysql_instance_class" {
  description = "Amazon RDS MySQL instance class."
  type        = string
  default     = "db.t4g.micro"
}

variable "mysql_allocated_storage" {
  description = "Initial RDS allocated storage in GiB."
  type        = number
  default     = 20
}

variable "mysql_max_allocated_storage" {
  description = "Maximum RDS autoscaled storage in GiB."
  type        = number
  default     = 100
}

variable "mysql_backup_retention_days" {
  description = "RDS backup retention period in days."
  type        = number
  default     = 7
}

variable "mysql_master_username" {
  description = "Bootstrap MySQL administrator username."
  type        = string
  sensitive   = true
}

variable "mysql_master_password" {
  description = "Bootstrap MySQL administrator password."
  type        = string
  sensitive   = true
}

variable "deletion_protection" {
  description = "Whether to enable deletion protection for RDS instances."
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Whether to skip final RDS snapshots on destroy."
  type        = bool
  default     = false
}

variable "apply_immediately" {
  description = "Whether RDS changes should apply immediately."
  type        = bool
  default     = false
}

variable "mongodb_atlas_org_id" {
  description = "MongoDB Atlas organization ID."
  type        = string
}

variable "mongodb_atlas_project_name" {
  description = "MongoDB Atlas project name."
  type        = string
}

variable "mongodb_atlas_cluster_name" {
  description = "MongoDB Atlas cluster name for billing-service."
  type        = string
}

variable "mongodb_major_version" {
  description = "MongoDB major version for the Atlas cluster."
  type        = string
  default     = "7.0"
}

variable "mongodb_atlas_provider_name" {
  description = "MongoDB Atlas provider name. TENANT supports shared-tier clusters."
  type        = string
  default     = "TENANT"
}

variable "mongodb_atlas_backing_provider_name" {
  description = "Cloud provider backing the MongoDB Atlas cluster."
  type        = string
  default     = "AWS"
}

variable "mongodb_atlas_region_name" {
  description = "MongoDB Atlas provider region name."
  type        = string
  default     = "US_EAST_1"
}

variable "mongodb_atlas_instance_size_name" {
  description = "MongoDB Atlas instance size."
  type        = string
  default     = "M0"
}

variable "billing_mongodb_database_name" {
  description = "MongoDB database name owned by billing-service."
  type        = string
  default     = "billing_service"
}

variable "billing_mongodb_username" {
  description = "MongoDB Atlas database username for billing-service."
  type        = string
  sensitive   = true
}

variable "billing_mongodb_password" {
  description = "MongoDB Atlas database password for billing-service."
  type        = string
  sensitive   = true
}

variable "mongodb_atlas_ip_access_list" {
  description = "CIDR blocks allowed to access the billing MongoDB Atlas cluster."
  type = list(object({
    cidr_block = string
    comment    = string
  }))
  default = []
}

variable "tags" {
  description = "Additional tags applied to AWS resources."
  type        = map(string)
  default     = {}
}
