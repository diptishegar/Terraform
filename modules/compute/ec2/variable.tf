variable "project_name" {
    type = string
    description = "Project/Environment to standardise the servers"
    default = "rapidconnect"
}

variable "key_name" {
  type = string
}

variable "subnet_id" {
  type = string
  description = "Subnet Id the EC2 is attached to"
}

variable "security_groups" {
  type = set(string)
}

variable "ec2_instance_type" {
  type = string
  default = "t2.micro"
}

variable "ec2_ami_id" {
  type = string
  default = "ami-02b8269d5e85954ef"
}
 
variable "is_public" {
    type = bool
    default = true
}