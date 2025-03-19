data "aws_availability_zones" "name" {
  state = "available"
}

# resource "random_integer" "integer" {
#   count = length(local.all_cidrs)
#   min = 1
#   max = 100
# }

resource "aws_vpc" "main" {
  enable_dns_support   = true
  enable_dns_hostnames = true
  cidr_block = var.vpc_cidr_block
  tags = merge(var.tags, local.common_tags)
}

resource "aws_subnet" "private" {
    count = length(var.private_subnet_cidrs)
    vpc_id            = aws_vpc.main.id
    cidr_block        = var.private_subnet_cidrs[count.index]
    availability_zone = data.aws_availability_zones.name.names[count.index]
    #tags = merge(var.tags, local.common_tags, {Name = "${local.name_prefix}${random_integer.integer[count.index].result}"})
    tags = merge(
        {
            Name = try(
                var.private_subnet_names[count.index],
                format("${local.name_prefix}-private-%s", element(data.aws_availability_zones.name.names, count.index))
        )},
        var.tags,
        local.common_tags
    )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.tags, local.common_tags)
}

resource "aws_route_table_association" "private" {
  count = var.create_private_subnets ? length(var.private_subnet_cidrs) : 0
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
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
                format("${local.name_prefix}-public-%s", element(data.aws_availability_zones.name.names, count.index))
        )},
        var.tags,
        local.common_tags
    )
}

resource "aws_route_table" "public" {
  #count = var.create_public_subnets ? length(var.public_subnet_cidrs) : 0
  vpc_id = aws_vpc.main.id
  tags = merge(var.tags, local.common_tags)
}

resource "aws_route_table_association" "public" {
    count = var.create_public_subnets ? length(var.public_subnet_cidrs) : 0
  
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}



resource "aws_nat_gateway" "nat_gateway" {
  count = length(var.public_subnet_cidrs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
}

resource "aws_eip" "nat" {
  count = length(aws_subnet.public)
  vpc = true
  tags = merge(var.tags, local.common_tags)
  
}

resource "aws_internet_gateway" "igw" { 
  vpc_id = aws_vpc.main.id
  tags = merge(var.tags, local.common_tags)
}