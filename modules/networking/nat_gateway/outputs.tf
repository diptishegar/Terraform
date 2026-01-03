output "nat_gateway_ids" {
  description = "Map of NAT Gateway IDs"
  value       = { for k, v in aws_nat_gateway.this : k => v.id }
}

output "eip_ids" {
  description = "Map of EIP IDs"
  value       = { for k, v in aws_eip.this : k => v.id }
}
