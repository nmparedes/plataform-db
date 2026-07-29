output "terraform_state_bucket_name" {
  description = "S3 bucket name for Terraform remote state."
  value       = aws_s3_bucket.terraform_state.bucket
}

output "terraform_state_lock_table_name" {
  description = "DynamoDB table name for Terraform state locking."
  value       = aws_dynamodb_table.terraform_lock.name
}

output "terraform_state_region" {
  description = "AWS region where the backend resources were created."
  value       = var.aws_region
}

output "terraform_state_key_prefix" {
  description = "Backend key prefix to reuse in the main platform-db stack."
  value       = var.state_key_prefix
}
