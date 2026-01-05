terraform {
  required_version = "~> 1.13.0"
  backend "s3" {
    bucket         = "rapidconnect-terraform-state"
    key            = "terraform/workspace.statefile"
    region         = "ap-south-1"
    use_lockfile   = true 
    encrypt        = true
  } 

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>6.20.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}