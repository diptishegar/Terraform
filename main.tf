module "rapidconnect_vpc" {
    source = "./modules/vpc"
    vpc_cidr_block = var.vpc_cidr_block
    subnet_configuration = var.subnet_configuration
}

#For Outbound internet access from private subnets
module "nat_gateway" {
  source = "./modules/networking/nat_gateway"

  enable_nat_gateway = false

  nat_gateways = {
    ap-south-1a = {
      subnet_id = module.rapidconnect_vpc.subnet_ids["public1"]
      tags = {
        Name = "nat_gateway-ap-south-1a"
      }
    }
  }
}

module "route_table_public" {
  source = "./modules/networking/route_table"

    route_tables = {
        public1 = {
        gateway_id = module.rapidconnect_vpc.rapidconnect_igw_id
        vpc_id     = module.rapidconnect_vpc.vpc_id
        subnet_id  = module.rapidconnect_vpc.subnet_ids["public1"]
        cidr_block = "0.0.0.0/0"
        is_public  = true
    }, public2 = {
        gateway_id = module.rapidconnect_vpc.rapidconnect_igw_id
        vpc_id     = module.rapidconnect_vpc.vpc_id
        subnet_id  = module.rapidconnect_vpc.subnet_ids["public2"]
        cidr_block = "0.0.0.0/0"
        is_public  = true
    }
}

depends_on = [ module.rapidconnect_vpc.rapidconnect_igw_id ]
}

module "aws_eks_cluster" {
  source = "./modules/compute/eks"

  cluster_name = "rapidconnect-eks-cluster"
  is_bootstrap_self_managed_addons = true
  eks_subnet_ids = [module.rapidconnect_vpc.subnet_ids["private1"], module.rapidconnect_vpc.subnet_ids["private2"]]
  eks_version_id = "1.30"
  node_group_name = "rapiconn-node-grp"
  users_arns = var.iam_user_arns
  owners = var.owners
}

/*
#My ECR Repository
data "aws_ecr_repository" "aws_ecr_repo" {
  name = "rapidconnect"
}
*/