
variable "cluster_name" {
    type = string
    description = "Name of the EKS Cluster"
}
variable "cluster_version" {
    type = string
    description = "Kubernetes version for the EKS Cluster"
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