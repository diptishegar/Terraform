
variable "cluster_name" {
    type = string
    description = "Name of the EKS Cluster"
}

variable "eks_node_group_policy_arns" {
  description = "List of additional IAM policy ARNs to attach to the EKS Node Group role"
  type        = list(string)
  default     = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
  ]
}

variable "eks_subnet_ids" {
  description = "Subnets Ids of the EKS Cluster"
  type = set(string)
}

variable "eks_version_id" {
    description = "EKS Cluster Version Id"
    type = string
}

variable "is_bootstrap_self_managed_addons" {
  description = "Cluster to install add-ons like Kube-proxy, CNI, CoreDNS if enabled"
  type = bool
}

variable "node_group_name" {
  description = "Node group name for the cluster's self managed node group"
  type = string
}

variable "instance_types" {
  description = "Instance Type for the node groups"
  type = list(string)
  default = ["t2.micro"]
}

variable "scaling_config" {
  description = "Scaling configuration for the node group"
  type = object({
    desired_size = number
    max_size     = number
    min_size     = number
  })

  default = {
  desired_size = 1
  max_size     = 2
  min_size     = 1

  }
}

variable "node_group_ami" {
  type = string
  description = "AMI Type for the node group instances"
  default = "ami-02b8269d5e85954ef"
}

variable "security_groups" {
  type = set(string)
}

variable "users_arns" {
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