# TAGS variables
variable "owner" {
  type = string
}
variable "project" {
  type = string
}

variable "domain_name" {
  description = "the name of the domain"
  default     = "lsccraffler"
}

variable "environment" {
  description = "the name of the environment were we are running things"
  type        = string
}

# variable "certificate_arn" {
#   description = "The certificate arn for https"
#   type = string
# }

variable "rolling_update" {
  description = "Do we use rolling_updates?"
  type        = string
  default     = "false"
}

variable "retention_policy" {
  description = "How many days we retain the cloudwatch logs"
  default     = 7
  type        = number
}

# variable "healthcheck_location" {
#   description = "Location endpoint for the healthcheck"
#   type = string
# }

variable "min_nodes" {
  description = "Minimum numbers of nodes to be handled by the autoscaling"
  type        = string
}

variable "max_nodes" {
  description = "Maximum numbers of nodes to be handled by the autoscaling"
  type        = string
}

variable "instance_type" {
  description = "The type of instance of the EC2 VMs"
  default     = "t2.micro"
}

variable "ip_prefix" {
  description = "The first two elements of the ip used to calculate the IP of the machines"
  type        = string
}

# variable "aws_region" {
#   description = "Region to use for the VPC"
#   # London is the default region for the whole project.
#   default = "eu-west-2"
# }

# variable "vpc_cidr" {
#   description = "Internal IP range, allowed to ssh to instances"
#   default = ".0.0/16"
# }

# variable "primary_private_cidr" {
#   description = "CIDR for the Primary Private Subnet"
#   default = ".100.0/24"
# }

# variable "secondary_private_cidr" {
#   description = "CIDR for the Secondary Private Subnet"
#   default = ".101.0/24"
# }

# variable "primary_public_cidr" {
#   description = "CIDR for the Primary Public Subnet"
#   default = ".0.0/24"
# }

# variable "secondary_public_cidr" {
#   description = "CIDR for the Secondary Public Subnet"
#   default = ".1.0/24"
# }

# variable "ssh_key" {
#   description = "ID of key pair that will be granted SSH access to the servers"
#   default = "lsccraffler"
# }

# variable "loadbalancing_desired_nodes" {
#     default = 2
#     description = "Desired amount of nodes in autoscaling group"
# }
