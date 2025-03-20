variable "create_public_subnets" {
  description = "specify whether public subnets are required"
  type        = bool
  default = true

}

variable "create_private_subnets" {
  description = "specify whether private subnets are required"
  type = bool
  default = true
}

variable "create_private_subnet_acl" {
  description = "Will the private subnets have a separate network ACL? Defaults to false"
  type = bool
  default = false
}

variable "project" {
    description = "project name infra being deployed for. Used in local_prefix variable for naming/tagging"
  default = "vrume"

}

variable "target_environment" {
  description = "Envrionment to be deployed"
  type        = string
  default = "dev"

  validation {
    condition     = contains(["dev", "stg", "prod"], var.target_environment)
    error_message = "value must be one of 'dev', 'stg', 'prod'"
  }

}

variable "vpc_cidr_block" {
  description = "CIDR block for use by subnets inside of your VPC"
  type        = string
  default = "10.0.0.0/16"

}

variable "tags" {
  description = "additional tags for the resource that are not required tags"
  type        = map(string)
  default = {}
}

variable "private_subnet_names" {
  description = "used if you want to manually map subnet names to subnets"
  type    = list(string)
  default = []

}

variable "private_subnet_cidrs" {
  description = "list of CIDR blocks for each required private subnet"
  type        = list(string)

  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  validation {
    #condition = length(var.private_subnet_cidrs) < 5
    condition     = length(var.private_subnet_cidrs) <= length(data.aws_availability_zones.name.names)
    error_message = "more subnets listed than AZ's available - one subnet per AZ"
  }
}

variable "public_subnet_cidrs" {
  description = "list of CIDR blocks for each required public subnet"
  type        = list(string)

  default = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]

  validation {
    #condition = length(var.private_subnet_cidrs) < 5
    condition     = length(var.public_subnet_cidrs) <= length(data.aws_availability_zones.name.names)
    error_message = "more subnets listed than AZ's available - one subnet per AZ"
  }
}

# variable "public_subnet_cidrs" {
#   description = "list of CIDR blocks for each required public subnet"

#   type = map(object({
#     az = optional(string, "us-west-2a")
#     cidr = string
#   }))
#   default = {
#     sub1 = {
#         cidr = "10.0.11.0/24"
#     }
#     sub2 = {
#         cidr = "10.0.12.0/24"
#         az = "us-west-2b"
#     }
#   }
# }

# variable "private_subnet_cidrs" {
#   description = "list of CIDR blocks for each required public subnet"

#   type = map(object({
#     az = optional(string, "us-west-2a")
#     cidr = string
#   }))
#   default = {
#     sub1 = {
#         cidr = "10.0.1.0/24"
#     }
#     sub2 = {
#         cidr = "10.0.2.0/24"
#         az = "us-west-2b"
#     }
#   }
# }
