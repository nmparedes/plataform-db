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
    project_id   = mongodbatlas_project.main.id
    cluster_name = mongodbatlas_cluster.billing.name
    srv_address  = mongodbatlas_cluster.billing.srv_address
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
