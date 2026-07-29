locals {
  common_tags = merge(var.tags, {
    Project    = var.project_name
    ManagedBy  = "terraform"
    Repository = "platform-db"
    Layer      = "bootstrap"
  })
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.state_bucket_name

  tags = merge(local.common_tags, {
    Name = var.state_bucket_name
  })
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform_lock" {
  name         = var.state_lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(local.common_tags, {
    Name = var.state_lock_table_name
  })
}
