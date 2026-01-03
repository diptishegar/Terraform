resource "aws_security_group" "this" {
    for_each = var.security_group
    
    name        = each.key
    description = each.value.description
    vpc_id      = each.value.vpc_id
    
    dynamic "ingress" {
        for_each = each.value.ingress
        content {
        from_port   = ingress.value.from_port
        to_port     = ingress.value.to_port
        protocol    = ingress.value.protocol
        cidr_blocks = ingress.value.cidr_blocks
        }
    }
    
    dynamic "egress" {
        for_each = each.value.egress
        content {
        from_port   = egress.value.from_port
        to_port     = egress.value.to_port
        protocol    = egress.value.protocol
        cidr_blocks = egress.value.cidr_blocks
        }
    }
    
    tags = each.value.tags
}