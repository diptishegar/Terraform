resource "aws_ecr_repository" "flaskapp-ecr-repo" {
  image_tag_mutability = "MUTABLE"
  name                 = "flaskapp"
  region               = "ap-south-1"
  tags                 = {}
  tags_all             = {}
  encryption_configuration {
    encryption_type = "AES256"
    kms_key         = null
  }
  image_scanning_configuration {
    scan_on_push = false
  }
}