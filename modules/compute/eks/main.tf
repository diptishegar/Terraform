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
    role_arn = aws_iam_role.eks_cluster_role.arn

    access_config {
        authentication_mode = "API_AND_CONFIG_MAP" 
    }

    vpc_config {
      subnet_ids = var.eks_subnet_ids
      security_group_ids = var.security_groups
      endpoint_public_access = true
      endpoint_private_access = true
    }

    encryption_config {
    resources = ["secrets"]

    provider {
      key_arn = aws_kms_key.eks_secrets.arn
    }
  }

    depends_on = [ aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy]

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

# Worker nodes instances configuration
resource "aws_iam_instance_profile" "this" {
  name = "${var.cluster_name}-node-instance-profile"
  role = aws_iam_role.eks_node_role.name
}

#Self-managed Ubuntu nodes must explicitly run the EKS bootstrap script.
locals {
  eks_bootstrap_userdata = <<-EOF
    #!/bin/bash
    set -o xtrace

    apt-get update -y
    apt-get install -y awscli

    /etc/eks/bootstrap.sh ${aws_eks_cluster.this.name} \
      --apiserver-endpoint ${aws_eks_cluster.this.endpoint} \
      --b64-cluster-ca ${aws_eks_cluster.this.certificate_authority[0].data}
  EOF
}


resource "aws_kms_key" "eks_secrets" {
  description             = "KMS key for EKS secrets encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

#My self-managed worker nodes template
resource "aws_launch_template" "this" {
  name_prefix   = "${var.cluster_name}-lt"
  image_id      = var.worker_nodes_ami
  instance_type = "t2.micro"
  vpc_security_group_ids = aws_eks_cluster.this.vpc_config[0].security_group_ids

  iam_instance_profile {
    name = aws_iam_instance_profile.this.name
  }

  user_data = base64encode(local.eks_bootstrap_userdata)

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.cluster_name}-worker-node"
    }
  }
  metadata_options {
    http_tokens = "required"
  }
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

  # REQUIRED for EKS + autoscaler later
  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }
}

