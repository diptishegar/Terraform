variable "route_tables" {
  description = "Map of route tables to create"
  type = map(object({
    gateway_id = string
    vpc_id = string
    subnet_id = string
    cidr_block = string
    is_public = bool
  }))
}