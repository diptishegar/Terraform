output "ec2_IP" {
  value = var.is_public?aws_instance.this.public_ip:"Instance Private"
}

output "security_groups" {
  value = aws_instance.this.vpc_security_group_ids
}