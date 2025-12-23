
#To import below existing AWS resources into Terraform state, use the following commands:
/*
Format to import :
import {
  id = "<YOUR_RESOURCE_ID"
  to = <HCL_ARG>.<YOUR_ARG_NAME>
}
*/
#vpc
import {
    id = "vpc-07e3f8c9c0e710f43"
    to = aws_vpc.flaskapp-vpc
}

#subnet
import {
    id = "subnet-04867dbab74a264ee"
    to = aws_subnet.flaskapp-subnet
}

#internet gateway
import {
    id = "igw-09caa830cff157957"
    to = aws_internet_gateway.flaskapp-igw
}

#route table
import {
    id = "rtb-06eb4d5c0b8f53254"
    to = aws_route_table.flaskapp-route-table
}

#security group
import {
  id = "sg-0c0709797181a9123"
  to = aws_security_group.flaskapp-sg
}

# EC2 instance
import {
  id = "i-01276596f18ea359e"
  to = aws_instance.flaskapp-ec2
}


#iam role
import {
  id = "ECRFullaccess-github"
  to = aws_iam_role.ecr-github-actions-role
}

import {
  id = "ECR-EC2-Image-Read"
  to = aws_iam_role.ecr-ec2-role
}

#iam policy
import {
  id = "arn:aws:iam::${var.account_id}:policy/ecr-ec2-policy"
  to = aws_iam_policy.ecr-ec2-policy 
}

#Github OIDC Provider
import {
  id = "arn:aws:iam::${var.account_id}:oidc-provider/token.actions.githubusercontent.com"
  to = aws_iam_openid_connect_provider.github-oidc-provider
}


#policy attachment
import {
  id = "ECR-EC2-Image-Read/arn:aws:iam::${var.account_id}:policy/ecr-ec2-policy"
  to = aws_iam_role_policy_attachment.ecr-ec2-policy-attachment-custom
}

import {
  id = "ECR-EC2-Image-Read/arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  to = aws_iam_role_policy_attachment.ecr-ec2-policy-attachment-aws
}

import {
  id = "ECRFullaccess-github/arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  to = aws_iam_role_policy_attachment.ecr-github-actions-policy-attachment
}


#ecr
import {
  id = "flaskapp"
  to = aws_ecr_repository.flaskapp-ecr-repo
}




