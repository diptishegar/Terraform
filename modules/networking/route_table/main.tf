resource "aws_route_table" "this" {
  for_each = var.route_tables
  vpc_id = each.value.vpc_id

  route {
    cidr_block = each.value.cidr_block
    gateway_id = each.value.gateway_id
  }

  tags = {
    Name = "rapidconnect-route-table-${each.value.is_public ? "public" : "private"}"
  } 
}

resource "aws_route_table_association" "this" {
  for_each = var.route_tables
  subnet_id      = each.value.subnet_id
  route_table_id = aws_route_table.this[each.key].id
  depends_on = [ aws_route_table.this ]
}