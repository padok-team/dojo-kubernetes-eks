output "node_security_group_id" {
  description = "The private subnets of the EKS cluster."
  value       = module.eks.node_security_group_id
}

output "how_to" {
  value = templatefile(
    "how_to.tpl",
    {
      env              = var.context.env,
      region           = var.context.region,
      cluster_name     = module.eks.cluster_name,
      cluster_arn      = module.eks.cluster_arn,
      cluster_endpoint = split("/", module.eks.cluster_endpoint)[2],
    }
  )
}
