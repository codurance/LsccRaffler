module "elb" {
  source         = "../../modules/elb"
  environment    = var.environment
  rolling_update = var.rolling_update
  min_nodes      = var.min_nodes
  max_nodes      = var.max_nodes
  instance_type  = var.instance_type
  ip_prefix      = var.ip_prefix
  owner          = var.owner
  project        = var.project
}
