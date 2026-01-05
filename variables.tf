variable "aws_region" {
    type        = string
    description = "AWS Region for Rapid Connect Deployment"
}

variable "vpc_cidr_block" {
  type = string
  description = "CIDR block for my VPC"
}
variable "subnet_configuration" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
    is_public         = bool
  }))
  description = "Subnet configuration for my VPC"
}

variable "iam_user_arns" {
  type = list(object({
    userarn = string
    username = string
    groups = list(string) 
  }))
  description = "ARN for the users to access cluster through"
 
}


variable "owners" {
  type = list(string)
  description = "Owners of the AMI Ids"
}

variable "security_ingress" {
  description = "List of ingress rules"
  type = list(object({
    description = optional(string)
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}





