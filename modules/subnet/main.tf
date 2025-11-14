resource "aws_subnet" "public" {
  for_each = { for idx, cidr in var.public_subnets_cidr : idx => cidr }
  
  vpc_id                  = var.vpc_id
  cidr_block              = each.value
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
  
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-public-${each.key + 1}"
    Type = "Public"
  })
}

resource "aws_route_table" "public" {
  vpc_id = var.vpc_id
  
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-public-rt"
    Type = "Public"
  })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.internet_gateway_id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public
  
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_network_acl_rule" "public_inbound_ports" {
  for_each = toset(var.public_nacl_inbound_ports)

  network_acl_id = aws_network_acl.public.id
  rule_number    = 100 + each.key
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.public_nacl_cidr
  from_port      = each.value
  to_port        = each.value
}

resource "aws_network_acl_rule" "public_inbound_ephemeral" {
  count = var.public_nacl_inbound_ephemeral ? 1 : 0

  network_acl_id = aws_network_acl.public.id
  rule_number    = 200
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.public_nacl_cidr
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "public_outbound_ports" {
  for_each = toset(var.public_nacl_outbound_ports)

  network_acl_id = aws_network_acl.public.id
  rule_number    = 300 + each.key
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.public_nacl_cidr
  from_port      = each.value
  to_port        = each.value
}

resource "aws_network_acl_rule" "public_outbound_ephemeral" {
  count = var.public_nacl_outbound_ephemeral ? 1 : 0

  network_acl_id = aws_network_acl.public.id
  rule_number    = 400
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.public_nacl_cidr
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  network_acl_id = aws_network_acl.public.id
}