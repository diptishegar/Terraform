variable "security_group" {
    description = "Security group's ingress and egress values"
    type = map(object({
      description = string
      ingress     = list(object({
        from_port   = number
        to_port     = number
        protocol    = string
        cidr_blocks = list(string)
      }))
      egress      = list(object({
        from_port   = number
        to_port     = number
        protocol    = string
        cidr_blocks = list(string)
      }))
      vpc_id      = string
      tags        = map(string)
    })) 
}