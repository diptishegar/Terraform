resource "aws_instance" "this" {
  instance_type = var.ec2_instance_type
  ami = var.ec2_ami_id
  vpc_security_group_ids = var.security_groups
  associate_public_ip_address = var.is_public
  subnet_id = var.subnet_id
  key_name = var.key_name

  tags = {
    Name = "instance_${var.project_name}"
  }

}