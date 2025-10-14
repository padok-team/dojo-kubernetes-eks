output "this" {
  description = "VPC Object."
  value       = module.vpc
}

output "bastion_security_group_id" {
  description = "The security group ID for the SSM Bastion."
  value       = module.ssm_bastion.security_group_id
}
