variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for EKS outbound access"
  type        = bool
  default     = false
}

variable "nat_gateways" {
  description = "Map of NAT gateways to create"
  type = map(object({
    subnet_id = string
    tags      = map(string)
  }))
}