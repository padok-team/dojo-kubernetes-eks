# SSM Bastion to connect to EKS trough an SSH tunnel
module "ssm_bastion" {
  source = "../bastion-ssm/"

  context    = var.context
  subnet_ids = module.vpc.private_subnets
  vpc_id     = module.vpc.vpc_id
}
