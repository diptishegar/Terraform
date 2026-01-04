output "subnet_ids" {
  description = "Map of Public Subnet IDs"
  value       = { for k, v in aws_subnet.rapidconnect_subnet : k => v.id }
}

output "rapidconnect_igw_id" {
  value = aws_internet_gateway.rapidconnect_igw.id
}

output "vpc_id" {
  value = aws_vpc.this.id
}