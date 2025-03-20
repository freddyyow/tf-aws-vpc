output "vpc-id" {
  value = aws_vpc.main.id
}

output "public-subnet-id" {
    value = [ for subnet in aws_subnet.public : subnet.id]
}

output "private-subnet-id" {
    value = [ for subnet in aws_subnet.private : subnet.id]
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