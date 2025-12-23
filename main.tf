
resource "aws_internet_gateway" "flaskapp-igw" {
  region = "ap-south-1"
  tags = {
    Name = "flaskapp-igw"
  }
  vpc_id = "vpc-07e3f8c9c0e710f43"
}

# __generated__ by Terraform from "sg-0c0709797181a9123"
resource "aws_security_group" "flaskapp-sg" {
  description = "sg for flaskapp"
  egress = [
     {
  description      = "Allow all outbound"
  from_port        = 0
  to_port          = 0
  protocol         = "-1"

  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = []

  prefix_list_ids  = []
  security_groups  = []
  self             = false
}
  ]
  ingress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description = "Allow SSH"
    from_port        = 22
    protocol         = "tcp"
    to_port          = 22
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
    }, {
    cidr_blocks      = ["0.0.0.0/0"]
    description = "Allow 443"
    from_port        = 443
    protocol         = "tcp"
    self             = false
    to_port          = 443
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false

  }]
  name                   = "flaskapp-sg"
  region                 = "ap-south-1"
  vpc_id                 = "vpc-07e3f8c9c0e710f43"
}

# __generated__ by Terraform
resource "aws_route_table" "flaskapp-route-table" {
  route = [{
    cidr_block                 = "0.0.0.0/0"
    gateway_id                 = "igw-09caa830cff157957"
     nat_gateway_id             = null
    transit_gateway_id         = null
    vpc_peering_connection_id  = null
    network_interface_id       = null
    vpc_endpoint_id            = null
    egress_only_gateway_id     = null
    local_gateway_id           = null
    carrier_gateway_id         = null
    core_network_arn           = null
    destination_prefix_list_id = null
    ipv6_cidr_block            = null
  }]
  tags = {
    Name = "flaskapp-rtb-public"
  }
  vpc_id = "vpc-07e3f8c9c0e710f43"
}

# __generated__ by Terraform
resource "aws_subnet" "flaskapp-subnet" {
  availability_zone                              = "ap-south-1a"
  cidr_block                                     = "10.0.0.0/20"
  private_dns_hostname_type_on_launch            = "ip-name"
  region                                         = "ap-south-1"
  tags = {
    Name = "flaskapp-subnet-public1-ap-south-1a"
  }
  vpc_id = "vpc-07e3f8c9c0e710f43"
}

# __generated__ by Terraform
resource "aws_vpc" "flaskapp-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "flaskapp-vpc"
  }
}

# __generated__ by Terraform
resource "aws_instance" "flaskapp-ec2" {
  ami                                  = "ami-02b8269d5e85954ef"
  associate_public_ip_address          = false
  availability_zone                    = "ap-south-1a"
  instance_type                        = "t2.micro"
  key_name                             = "ap-south-1_sshkey"
  region                               = "ap-south-1"
  subnet_id                            = "subnet-04867dbab74a264ee"
  tags = {
    Name = "flaskapp-server"
  }
  tenancy                     = "default"
  vpc_security_group_ids      = ["sg-0c0709797181a9123"]
  private_dns_name_options {
    enable_resource_name_dns_a_record    = false
    enable_resource_name_dns_aaaa_record = false
    hostname_type                        = "ip-name"
  }
}
