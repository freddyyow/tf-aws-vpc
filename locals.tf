locals {
  common_tags = {
    Environment = var.target_environment
    DeployedWith = "Terraform"
    Owner = "SPIDR-Tech"

  }
  name_prefix = "${var.project}-${var.target_environment}"
 # cidr_list = concat(output.public-subnet-id)
  all_cidrs = concat(var.private_subnet_cidrs, var.public_subnet_cidrs)
}