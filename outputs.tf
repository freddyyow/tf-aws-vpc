output "vpc-id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.main.id
}

output "default-vpc-acl-id" {
  description = "ID for the default acl - used for public subnets"
  value       = aws_vpc.main.default_network_acl_id
}

output "availability-zones" {
  description = "value"
  value       = data.aws_availability_zones.name.names

}

output "vpc_cidr_block" {
  description = "CIDR used by the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public-subnet-id" {
  description = "ID's of all created public subnets"
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "private-subnet-id" {
  description = "ID's of all created private subnets"
  value       = [for subnet in aws_subnet.private : subnet.id]
}

output "public-rt-id" {
  description = "id of the public route table"
  value       = aws_route_table.public.id
}

output "private-rt-id" {
  description = "id of the private route table"
  value       = aws_route_table.private[*].id
}

output "nat-gateway-id" {
  description = "value"
  value       = aws_nat_gateway.nat_gateway[*].id

}

output "nat-eip" {
  description = "value"
  value       = aws_eip.nat[*].address
}

output "igw-id" {
  description = "ID of the internet gateway attached to the VPC"
  value       = aws_internet_gateway.igw.id
}

output "private-network-acl" {
  description = "value"
  value       = try(aws_network_acl.private[*].id, null)
}

# output "public-id" {
#     value = {for k, v in aws_subnet.public : k => v.id}

# }

# output "public-id" {
#     value = tolist([ for subnet in aws_subnet.public : subnet.id])

# }

# output "public-id" {
#     value = aws_subnet.public[*].id
# }