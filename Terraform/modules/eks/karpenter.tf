module "karpenter" {
  count   = var.context.enable_karpenter == true ? 1 : 0
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "20.37.1"

  cluster_name = module.eks.cluster_name

  # Attach additional IAM policies to the Karpenter node IAM role
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  tags = var.context.tags
}

resource "aws_eks_pod_identity_association" "this" {
  count           = var.context.enable_karpenter == true ? 1 : 0
  cluster_name    = module.eks.cluster_name
  namespace       = "karpenter"
  service_account = "karpenter"
  role_arn        = module.karpenter[0].iam_role_arn
}
