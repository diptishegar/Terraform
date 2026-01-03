variable "vpc_cidr_block" {
    type = string
    description = "CIDR Block for my VPC"
}

variable "aws_region" {
    type = string
    description = "AWS Region to deploy resources"
    default = "ap-south-1"
}

variable "subnet_configuration" {
    type = map(object({
      cidr_block = string
      availability_zone = string
      is_public = bool
    }))
    description = "Dynamic Subnet Configuration"
}

variable "vpc_id" {
  type = string
  description = "VPC Id for my module"
}
