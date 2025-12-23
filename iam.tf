# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform
resource "aws_iam_openid_connect_provider" "github-oidc-provider" {
  client_id_list  = ["sts.amazonaws.com"]
  tags            = {}
  tags_all        = {}
  thumbprint_list = ["2b18947a6a9fc7764fd8b5fb18a863b0c6dac24f"]
  url             = "https://token.actions.githubusercontent.com"
}

# __generated__ by Terraform from "arn:aws:iam::857565654393:policy/ecr-ec2-policy"
resource "aws_iam_policy" "ecr-ec2-policy" {
  description = null
  name        = "ecr-ec2-policy"
  name_prefix = null
  path        = "/"
  policy = jsonencode({
    Statement = [{
      Action   = ["ecr:GetAuthorizationToken"]
      Effect   = "Allow"
      Resource = "*"
      Sid      = "Statement1"
      }, {
      Action   = ["ecr:BatchCheckLayerAvailability", "ecr:GetDownloadUrlForLayer", "ecr:BatchGetImage"]
      Effect   = "Allow"
      Resource = ["*"]
      Sid      = "Statement2"
    }]
    Version = "2012-10-17"
  })
  tags     = {}
  tags_all = {}
}

# __generated__ by Terraform from "ECRFullaccess-github"
resource "aws_iam_role" "ecr-github-actions-role" {
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = ["repo:diptishegar/secure-webapp-deployment:*", "repo:diptishegar/secure-webapp-deployment:*"]
        }
      }
      Effect = "Allow"
      Principal = {
        Federated = "arn:aws:iam::857565654393:oidc-provider/token.actions.githubusercontent.com"
      }
    }]
    Version = "2012-10-17"
  })
  description           = null
  force_detach_policies = false
  max_session_duration  = 3600
  name                  = "ECRFullaccess-github"
  name_prefix           = null
  path                  = "/"
  permissions_boundary  = null
  tags                  = {}
  tags_all              = {}
}

# __generated__ by Terraform from "ECR-EC2-Image-Read"
resource "aws_iam_role" "ecr-ec2-role" {
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
  description           = "Allows EC2 instances to call AWS services on your behalf."
  force_detach_policies = false
  max_session_duration  = 3600
  name                  = "ECR-EC2-Image-Read"
  name_prefix           = null
  path                  = "/"
  permissions_boundary  = null
  tags                  = {}
  tags_all              = {}
}


resource "aws_iam_role_policy_attachment" "ecr-github-actions-policy-attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  role       = "ECRFullaccess-github"
}

resource "aws_iam_role_policy_attachment" "ecr-ec2-policy-attachment-custom" {
  policy_arn = "arn:aws:iam::857565654393:policy/ecr-ec2-policy"
  role       = "ECR-EC2-Image-Read"
}

resource "aws_iam_role_policy_attachment" "ecr-ec2-policy-attachment-aws" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "ECR-EC2-Image-Read"
}