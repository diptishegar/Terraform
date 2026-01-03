output "vpc_id" {
  description = "VPC Id of Rapidconnect module"
  value = aws_vpc.rapidconnect_vpc.id
}

output "public_subnet_ids" {
  description = "Map of Public Subnet IDs"
  value       = { for k, v in aws_subnet.rapidconnect_subnet : k => v.id }
}

output "rapidconnect_igw_id" {
  value = aws_internet_gateway.rapidconnect_igw.id
}