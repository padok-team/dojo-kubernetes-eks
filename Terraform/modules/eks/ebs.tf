resource "aws_iam_role_policy_attachment" "this" {
  for_each   = var.context.ebs_csi_attach ? { for idx, ng in module.eks.eks_managed_node_groups : idx => ng.iam_role_name } : {}
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = each.value
}
