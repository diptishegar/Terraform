output "route_table_association_ids" {
  description = "A map of input keys to their corresponding Route Table Association IDs"
  value       = { for k, v in aws_route_table_association.this : k => v.id }
}