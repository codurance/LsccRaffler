variable "domain_name" {
  description = "the name of the domain"
  default = "lsccraffler"
}

variable "workspace_to_environment_map" {
  description = "The name of the environment to use for the application"
  type = "map"
  default = {
    dev = "dev"
    prod = "prod"
  }
}

variable "workspace_to_base_environment_map" {
  description = "The name of the environment to use for the application"
  type = "map"
  default = {
    dev = "dev"
    prod = "prod"
  }
}

variable "workspace_to_waf_rule_map" {
  description = "The name of the environment to use for the application"
  type = "map"
  default = {
    dev = "dev"
    prod = "prod"
  }
}

variable "workspace_to_ip_map" {
  description = "The beginning of the ips to be used on the environment"
  type = "map"
  default = {
    dev = "172.32"
    prod = "172.34"
  }
}

variable "workspace_to_instance_type_map" {
  description = "The type of instance to use for the EC2 machines"
  type = "map"
  default = {
    dev = "t2.micro"
    prod = "t2.micro"
  }
}

variable "workspace_to_max_nodes_map" {
  description = "Maximum number of nodes (machines) that we want in the autoscaling group"
  type = "map"
  default = {
    dev = "2"
    prod = "5"
  }
}

variable "workspace_to_min_nodes_map" {
  description = "The minimum number of nodes (machines) that we want in the autoscaling group"
  type = "map"
  default = {
    dev = "2"
    prod = "2"
  }
}

variable "workspace_to_retention_policy_map" {
  description = "The retention policy for logs"
  type = "map"
  default = {
    dev = 7
    prod = 7
  }
}

variable "workspace_to_rolling_update_map" {
  description = ""
  type = "map"
  default = {
    dev = "false"
    prod = "false"
  }
}

variable "workspace_to_base_url_map" {
  description = "The base url for the application"
  type = "map"
  default = {
    dev = "https://lscc_raffler.codurance.io"
    prod = "https://lscc_raffer.codurance.com"
  }
}

# This needs to be done as part of terraform
variable "workspace_to_certification_map" {
  description = "The SSL certificate arn to use on the load balance of the environment"
  type = "map"
  default = {
    dev = "arn:aws:acm:eu-west-2:788981310941:certificate/2a83d884-ba10-477c-aace-986892e3a17d"
    prod = "arn:aws:acm:eu-west-2:788981310941:certificate/f15cfb5d-07d6-4c2a-b154-20f37371b3f2"
  }
}

locals {
  environment = "${lookup(var.workspace_to_environment_map, terraform.workspace, "test")}"
  waf_prefix = "${lookup(var.workspace_to_waf_rule_map, terraform.workspace)}"
  ip_prefix = "${lookup(var.workspace_to_ip_map, terraform.workspace, "172.32")}"
  certificate_arn = "${lookup(var.workspace_to_certification_map, terraform.workspace, "arn:aws:acm:eu-west-2:788981310941:certificate/2a83d884-ba10-477c-aace-986892e3a17d")}"
  base_url = "${lookup(var.workspace_to_base_url_map, terraform.workspace, "https://lscc_raffler.codurance.io")}"
  logs_prefix = "${lookup(var.workspace_to_base_environment_map, terraform.workspace, "test")}"
  retention_policy = "${lookup(var.workspace_to_retention_policy_map, terraform.workspace, 7)}"
  min_nodes = "${lookup(var.workspace_to_min_nodes_map, terraform.workspace, 2)}"
  max_nodes = "${lookup(var.workspace_to_max_nodes_map, terraform.workspace, 2)}"
  instance_type = "${lookup(var.workspace_to_instance_type_map, terraform.workspace, "t2.micro")}"
  rolling_update = "${lookup(var.workspace_to_rolling_update_map, terraform.workspace, "false")}"
}

variable "aws_region" {
  description = "Region to use for the VPC"
  # London is the default region for the whole project.
  default = "eu-west-2"
}

variable "vpc_cidr" {
  description = "Internal IP range, allowed to ssh to instances"
  default = ".0.0/16"
}

variable "primary_private_cidr" {
  description = "CIDR for the Primary Private Subnet"
  default = ".100.0/24"
}

variable "secondary_private_cidr" {
  description = "CIDR for the Secondary Private Subnet"
  default = ".101.0/24"
}

variable "primary_public_cidr" {
  description = "CIDR for the Primary Public Subnet"
  default = ".0.0/24"
}

variable "secondary_public_cidr" {
  description = "CIDR for the Secondary Public Subnet"
  default = ".1.0/24"
}

variable "ssh_key" {
  description = "ID of key pair that will be granted SSH access to the servers"
  default = "lsccraffler"
}

variable "healthcheck_location" {
    # default TCP:22 since application might not actually be running (it's new after all)
    default = "HTTP:80/healthcheck"
    description = "Location for Load balancer to check for response to see if instances in autoscaling group are healthy"
}  

variable "loadbalancing_desired_nodes" {
    default = 2
    description = "Desired amount of nodes in autoscaling group"
}
