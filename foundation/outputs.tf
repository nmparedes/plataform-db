output "vpc_id" {
  description = "VPC ID consumed by the managed database stack."
  value       = aws_vpc.main.id
}

output "private_subnet_ids" {
  description = "Private subnet IDs consumed by the managed database stack."
  value       = [for subnet in aws_subnet.private : subnet.id]
}

output "public_subnet_ids" {
  description = "Public subnet IDs created for the shared AWS foundation."
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "private_route_table_id" {
  description = "Private route table ID for future private workload integrations."
  value       = aws_route_table.private.id
}

output "vpc_cidr_block" {
  description = "CIDR block assigned to the shared VPC."
  value       = aws_vpc.main.cidr_block
}
