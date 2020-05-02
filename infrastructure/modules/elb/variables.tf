variable "environment" {
  description = "the name of the environment were we are running things"
  default     = "dev"
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

# variable "ssh_key" {
#   description = "The ssh key to log into the ec2 instances"
#   type = string
# }

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

# variable "vpc_cidr" {
#   description = "Internal IP range, allowed to ssh to instances"
#   default = ".0.0/16"
#   type = string
# }


