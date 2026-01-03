#IAM for the cluster
data "aws_iam_policy_document" "eks_cluster_assume_role_policy" {
    statement {
        effect = "Allow"
        principals {
            type        = "Service"
            identifiers = ["eks.amazonaws.com"]
        }
        actions = ["sts:AssumeRole"]
    }
}
resource "aws_iam_role" "eks_cluster_role" {
    name = "eks-cluster-role-${var.cluster_name}"
    assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume_role_policy.json
    tags = {
        Name = "eks-cluster-role-${var.cluster_name}"
    }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
    role       = aws_iam_role.eks_cluster_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

#IAM for the worker nodes
data "aws_iam_policy_document" "eks_node_assume_role_policy" {
    statement {
        effect = "Allow"
        principals {
            type        = "Service"
            identifiers = ["ec2.amazonaws.com"]
        }
        actions = ["sts:AssumeRole"]
    }
}

resource "aws_iam_role" "eks_node_role" {
    name = "eks-node-role-${var.cluster_name}"
    assume_role_policy = data.aws_iam_policy_document.eks_node_assume_role_policy.json
    tags ={
        Name = "eks-node-role-${var.cluster_name}"
    }
}

resource "aws_policy_attachment" "eks_node_AmazonEKSWorkerNodePolicy" {
    for_each = toset(var.eks_node_group_policy_arns)
    name       = "eks-node-AmazonEKSWorkerNodePolicy-${var.cluster_name}"
    roles      = [aws_iam_role.eks_node_role.name]
    policy_arn = each.value
}

#IAM IRSA role for ASG
data "aws_iam_policy_document" "cluster_autoscaler_policy" {
  statement {
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:DescribeLaunchTemplateVersions"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "cluster_autoscaler" {
  name        = "EKSClusterAutoscalerPolicy"
  policy      = data.aws_iam_policy_document.cluster_autoscaler_policy.json
}

#Create EKS CLuster
resource "aws_eks_cluster" "aws_eks_cluster" {
    name = var.cluster_name
    version = var.eks_version_id
    access_config {
        authentication_mode = "API_AND_CONFIG_MAP" 
    }

    role_arn = aws_iam_role.eks_cluster_role
    vpc_config {
      subnet_ids = var.eks_subnet_ids
      endpoint_public_access = true
      endpoint_private_access = true
    }

    depends_on = [ aws_policy_attachment.eks_cluster_AmazonEKSClusterPolicy ]

}

