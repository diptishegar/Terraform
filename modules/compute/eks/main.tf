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

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKSWorkerNodePolicy" {
    for_each = toset(var.eks_node_group_policy_arns)
    role     = aws_iam_role.eks_node_role.name
    policy_arn = each.value
}

#IAM IRSA role for ASG
data "aws_iam_policy_document" "cluster_autoscaler_policy" {
  statement {
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup"
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/kubernetes.io/cluster/${var.cluster_name}"
      values   = ["owned"]
    }
  }
}


resource "aws_iam_policy" "cluster_autoscaler" {
  name        = "EKSClusterAutoscalerPolicy"
  policy      = data.aws_iam_policy_document.cluster_autoscaler_policy.json
}

#Create EKS CLuster
resource "aws_eks_cluster" "this" {
    name = var.cluster_name
    version = var.eks_version_id
    bootstrap_self_managed_addons = var.is_bootstrap_self_managed_addons
    access_config {
        authentication_mode = "API_AND_CONFIG_MAP" 
    }

    role_arn = aws_iam_role.eks_cluster_role.arn
    vpc_config {
      subnet_ids = var.eks_subnet_ids
      endpoint_public_access = false
      endpoint_private_access = true
    }

      encryption_config {
    resources = ["secrets"]

    provider {
      key_arn = aws_kms_key.eks_secrets.arn
    }
  }

    depends_on = [ aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy, aws_kms_key.eks_secrets ]

}

#EKS OIDC Provider for the Pods to access AWS services
data "tls_certificate" "eks_oidc" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer

  depends_on = [ aws_eks_cluster.this ]
}

resource "aws_iam_openid_connect_provider" "eks" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint
  ]

  tags = {
    Name = "${var.cluster_name}-oidc-provider"
  }

  depends_on = [ aws_eks_cluster.this ]
}

# EC2 instances configuration
resource "aws_iam_instance_profile" "this" {
  name = "${var.cluster_name}-node-instance-profile"
  role = aws_iam_role.eks_node_role.name
}

#Self-managed Ubuntu nodes must explicitly run the EKS bootstrap script.
locals {
  eks_bootstrap_userdata = <<-EOF
    #!/bin/bash
    set -o xtrace

    /etc/eks/bootstrap.sh ${aws_eks_cluster.this.name}
  EOF
}

resource "aws_kms_key" "eks_secrets" {
  description             = "KMS key for EKS secrets encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_launch_template" "this" {
  name_prefix   = "${var.cluster_name}-lt-"
  image_id      = var.node_group_ami
  instance_type = "t2.micro"

  iam_instance_profile {
    name = aws_iam_instance_profile.this.name
  }

  user_data = base64encode(local.eks_bootstrap_userdata)

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.cluster_name}-worker"
    }
  }
}


#Create EKS Self-managed Node Groups
resource "aws_eks_node_group" "this" {
    cluster_name = var.cluster_name
    node_group_name = var.node_group_name

    subnet_ids = var.eks_subnet_ids
    instance_types = var.instance_types

    scaling_config {
    desired_size = var.scaling_config.desired_size
    max_size     = var.scaling_config.max_size
    min_size     = var.scaling_config.min_size
    }

    update_config {
    max_unavailable = 1
  }

    labels = {
      role = "worker"
    }
    node_role_arn = aws_iam_role.eks_node_role.arn
    tags = {
      Name = "node-group-${var.cluster_name}"
    }

    depends_on = [ aws_iam_role_policy_attachment.eks_node_AmazonEKSWorkerNodePolicy, aws_eks_cluster.this ]
}

#aws-auth configmap
resource "kubernetes_config_map_v1" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapUsers = yamlencode(var.users_arns)
    mapRoles = yamlencode([
      {
        rolearn = aws_iam_role.eks_node_role.arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups = [
          "system:bootstrappers",
          "system:nodes"
        ]
      }
    ])

    
  }

  depends_on = [
    aws_eks_node_group.this,
    aws_autoscaling_group.this
  ]
}


#Cluster auto-scaler
resource "aws_autoscaling_group" "this" {
  name                      = "${var.cluster_name}-asg"
  min_size                  = 1
  desired_capacity          = 1
  max_size                  = 2
  vpc_zone_identifier       = var.eks_subnet_ids
  health_check_type         = "EC2"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-worker"
    propagate_at_launch = true
  }

  # REQUIRED for EKS + autoscaler later
  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }
}


#verify everything with kubectl get nodes
