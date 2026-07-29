locals {
  use_foundation_remote_state = (
    var.foundation_state_bucket != null &&
    var.foundation_state_key != null &&
    var.foundation_state_region != null
  )

  foundation_vpc_id     = local.use_foundation_remote_state ? data.terraform_remote_state.foundation[0].outputs.vpc_id : var.vpc_id
  foundation_subnet_ids = local.use_foundation_remote_state ? data.terraform_remote_state.foundation[0].outputs.private_subnet_ids : var.private_subnet_ids

  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Repository  = "platform-db"
  })
}

data "terraform_remote_state" "foundation" {
  count   = local.use_foundation_remote_state ? 1 : 0
  backend = "s3"

  config = {
    bucket = var.foundation_state_bucket
    key    = var.foundation_state_key
    region = var.foundation_state_region
  }
}

check "network_inputs" {
  assert {
    condition = (
      local.use_foundation_remote_state ||
      (var.vpc_id != null && var.private_subnet_ids != null)
    )
    error_message = "Set foundation_state_bucket, foundation_state_key and foundation_state_region together, or provide both fallback values vpc_id and private_subnet_ids."
  }
}

resource "aws_db_subnet_group" "mysql" {
  name       = "${var.project_name}-${var.environment}-mysql"
  subnet_ids = local.foundation_subnet_ids

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-mysql"
  })
}

resource "aws_security_group" "mysql" {
  name        = "${var.project_name}-${var.environment}-mysql"
  description = "MySQL access for Phase 4 service-owned databases"
  vpc_id      = local.foundation_vpc_id

  dynamic "ingress" {
    for_each = var.allowed_mysql_cidr_blocks

    content {
      description = "MySQL from approved network"
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  egress {
    description = "Outbound access for managed database maintenance"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-mysql"
  })
}

resource "aws_db_instance" "mysql" {
  for_each = var.mysql_service_databases

  identifier              = "${var.project_name}-${each.key}-${var.environment}-mysql"
  db_name                 = each.value.database_name
  engine                  = "mysql"
  engine_version          = var.mysql_engine_version
  instance_class          = var.mysql_instance_class
  allocated_storage       = var.mysql_allocated_storage
  max_allocated_storage   = var.mysql_max_allocated_storage
  storage_encrypted       = true
  username                = var.mysql_master_username
  password                = var.mysql_master_password
  db_subnet_group_name    = aws_db_subnet_group.mysql.name
  vpc_security_group_ids  = [aws_security_group.mysql.id]
  publicly_accessible     = var.mysql_publicly_accessible
  backup_retention_period = var.mysql_backup_retention_days
  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : (
    "${var.project_name}-${each.key}-${var.environment}-final"
  )
  apply_immediately = var.apply_immediately

  tags = merge(local.common_tags, {
    Service  = each.value.service_name
    Database = each.value.database_name
  })
}

resource "aws_secretsmanager_secret" "mysql_connection" {
  for_each = var.mysql_service_databases

  name        = "${var.project_name}/${var.environment}/${each.value.service_name}/mysql"
  description = "Connection metadata for ${each.value.service_name} MySQL database"

  tags = merge(local.common_tags, {
    Service = each.value.service_name
  })
}

resource "aws_secretsmanager_secret_version" "mysql_connection" {
  for_each = var.mysql_service_databases

  secret_id = aws_secretsmanager_secret.mysql_connection[each.key].id
  secret_string = jsonencode({
    engine   = "mysql"
    host     = aws_db_instance.mysql[each.key].address
    port     = aws_db_instance.mysql[each.key].port
    database = each.value.database_name
    username = var.mysql_master_username
    password = var.mysql_master_password
  })
}

resource "aws_secretsmanager_secret" "billing_mongodb_connection" {
  name        = "${var.project_name}/${var.environment}/billing-service/mongodb"
  description = "Connection metadata for billing-service MongoDB Atlas database"

  tags = merge(local.common_tags, {
    Service = "billing-service"
  })
}

resource "aws_secretsmanager_secret_version" "billing_mongodb_connection" {
  secret_id = aws_secretsmanager_secret.billing_mongodb_connection.id
  secret_string = jsonencode({
    engine         = "mongodb"
    host           = var.billing_mongodb_srv_address
    database       = var.billing_mongodb_database_name
    username       = var.billing_mongodb_username
    password       = var.billing_mongodb_password
    connection_uri = var.billing_mongodb_connection_uri
  })
}
