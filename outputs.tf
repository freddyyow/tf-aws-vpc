# output "public-subnet-id" {
#     value = [ for subnet in aws_subnet.public : subnet.id]
# }

# output "private-id" {
#     value = [ for subnet in aws_subnet.private : subnet.id]
# }