data "aws_availability_zones" "name" {
  state = "available"
}

resource "aws_vpc" "main" {
  enable_dns_support   = true
  enable_dns_hostnames = true
  cidr_block           = var.vpc_cidr_block
  tags                 = merge(var.tags, local.common_tags, {Name = "${local.name_prefix}"})
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.name.names[count.index]
  #tags = merge(var.tags, local.common_tags, {Name = "${local.name_prefix}${random_integer.integer[count.index].result}"})
  tags = merge(
    {
      Name = try(
        var.private_subnet_names[count.index],
        format("${local.name_prefix}-priv-%s", element(data.aws_availability_zones.name.names, count.index))
    )},
    var.tags,
    local.common_tags
  )
}

resource "aws_route_table" "private" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id
  tags = merge(
    {
      Name = try(
        var.private_subnet_names[count.index],
        format("${local.name_prefix}-priv-rt-%s", element(data.aws_availability_zones.name.names, count.index))
    )},
    var.tags,
    local.common_tags
  )
}

resource "aws_route_table_association" "private" {
  count          = var.create_private_subnets ? length(var.private_subnet_cidrs) : 0
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
  #subnet_id      = aws_subnet.private[count.index].id
  #route_table_id = aws_route_table.private.id
}

resource "aws_subnet" "public" {
  count = var.create_public_subnets ? length(var.public_subnet_cidrs) : 0
  #count = length(var.eks_cidr_block)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.name.names[count.index]

  #tags = merge(var.tags, local.common_tags, {Name = "${local.name_prefix}${random_integer.integer[count.index].result}"})
  tags = merge(
    {
      Name = try(
        var.private_subnet_names[count.index],
        format("${local.name_prefix}-pub-%s", element(data.aws_availability_zones.name.names, count.index))
    ) },
    var.tags,
    local.common_tags
  )
}

resource "aws_route_table" "public" {
  #count = var.create_public_subnets ? length(var.public_subnet_cidrs) : 0
  vpc_id = aws_vpc.main.id
  tags = merge(var.tags, local.common_tags, {Name = "${local.name_prefix}-pub-rt"})
}

resource "aws_route_table_association" "public" {
  count = var.create_public_subnets ? length(var.public_subnet_cidrs) : 0

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_nat_gateway" "nat_gateway" {
  count         = length(var.public_subnet_cidrs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  #tags = merge(var.tags, local.common_tags, {Name = format("${local.name_prefix}-pub-%s", element(data.aws_availability_zones.name.names, count.index))},
  tags = merge(
    var.tags,
    local.common_tags,
    {Name = format("${local.name_prefix}-gw-%s", element(data.aws_availability_zones.name.names, count.index)),},
  )
}

resource "aws_eip" "nat" {
  count = length(aws_subnet.public)
  vpc   = true
  
  tags = merge(
    var.tags,
    local.common_tags,
    {Name = format("${local.name_prefix}-natgw-%s", element(data.aws_availability_zones.name.names, count.index)),},
  )

}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  
  tags = merge(
    var.tags,
    local.common_tags,
    {Name = "${local.name_prefix}-igw"}
  )
}

# resource "aws_network_acl" "public" {
#   vpc_id = aws_vpc.main.id
#   #  subnet_ids = 


# }

resource "aws_network_acl" "private" {
  count = var.create_private_subnet_acl ? 1 : 0
  #count = var.create_private_subnets ? length(var.private_subnet_cidrs) : 0
  vpc_id = aws_vpc.main.id
  # subnet_ids = toset(element(aws_subnet.private.*.id, count.index))
  tags = merge(
    var.tags,
    local.common_tags,
    {Name = "${local.name_prefix}-priv-acl"}
  )
}

resource "aws_network_acl_association" "private" {
  count = var.create_private_subnet_acl ? length(var.private_subnet_cidrs) : 0
  #count          = var.create_private_subnets ? length(var.private_subnet_cidrs) : 0
  network_acl_id = aws_network_acl.private[0].id
  subnet_id      = aws_subnet.private[count.index].id

}

# resource "aws_network_acl_rule" "private_inbound" {
#   count = var.create_private_subnets ? length(var.private_inbound_acl_rules) : 0
#   network_acl_id = 
# }

# resource "aws_network_acl_rule" "private_outbound" {

# }
# resource "aws_network_acl" "private" {
#   vpc_id = aws_vpc.main.id
# }
#aws_network_acl
#aws_network_acl_assocation
#aws_network_acl_rule
#vpc-03523668724c41c27