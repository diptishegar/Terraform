resource "aws_eip" "this" {
  for_each = var.enable_nat_gateway ? var.nat_gateways : {}

  domain = "vpc"

  tags = merge(
    {
      Name = "nat-eip-${each.key}"
    },
    each.value.tags
  )
}

resource "aws_nat_gateway" "this" {
  for_each = var.enable_nat_gateway ? var.nat_gateways : {}

  allocation_id = aws_eip.this[each.key].id
  subnet_id     = each.value.subnet_id

  tags = merge(
    {
      Name = "nat-gateway-${each.key}"
    },
    each.value.tags
  )

  depends_on = [aws_eip.this]
}
