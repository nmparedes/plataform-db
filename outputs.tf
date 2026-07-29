output "mysql_databases" {
  description = "Managed MySQL database endpoints and service ownership."
  value = {
    for service_key, instance in aws_db_instance.mysql : service_key => {
      service_name = var.mysql_service_databases[service_key].service_name
      database     = var.mysql_service_databases[service_key].database_name
      address      = instance.address
      endpoint     = instance.endpoint
      port         = instance.port
      secret_arn   = aws_secretsmanager_secret.mysql_connection[service_key].arn
    }
  }
}

output "billing_mongodb" {
  description = "MongoDB Atlas billing database metadata."
  value = {
    service_name = "billing-service"
    srv_address  = var.billing_mongodb_srv_address
    database     = var.billing_mongodb_database_name
    secret_arn   = aws_secretsmanager_secret.billing_mongodb_connection.arn
  }
}

output "service_database_secret_arns" {
  description = "Secret ARNs consumed by service deployments."
  value = merge(
    {
      for service_key, secret in aws_secretsmanager_secret.mysql_connection :
      var.mysql_service_databases[service_key].service_name => secret.arn
    },
    {
      "billing-service" = aws_secretsmanager_secret.billing_mongodb_connection.arn
    }
  )
}

output "network_configuration_source" {
  description = "Whether the managed database stack resolved network configuration from foundation remote state or explicit fallback variables."
  value = {
    source             = local.use_foundation_remote_state ? "foundation-remote-state" : "explicit-variables"
    vpc_id             = local.foundation_vpc_id
    private_subnet_ids = local.foundation_subnet_ids
  }
}
