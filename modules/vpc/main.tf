resource "aws_vpc" "rapidconnect_vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "rapidconnect-vpc"
  }
}

resource "aws_subnet" "rapidconnect_subnet" {
    for_each = var.subnet_configuration

    vpc_id            = var.vpc_id
    cidr_block        = each.value.cidr_block
    availability_zone = each.value.availability_zone
    map_public_ip_on_launch = each.value.is_public
    tags = {
        Name = "rapidconnect-subnet-${each.value.availability_zone}-${each.key}"
    }
}

resource "aws_internet_gateway" "rapidconnect_igw" {
  vpc_id = var.vpc_id

  tags = {
    Name = "rapidconnect-igw"
  }
  
}