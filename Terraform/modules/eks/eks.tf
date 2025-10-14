
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.37.1"

  cluster_name    = "${var.context.env}-${var.context.cluster_name}"
  cluster_version = var.context.cluster_version
  cluster_addons  = var.context.cluster_addons

  # Network config
  vpc_id                               = var.context.vpc_id
  subnet_ids                           = var.context.vpc_private_subnets_ids
  cluster_service_ipv4_cidr            = var.context.service_ipv4_cidr
  cluster_endpoint_public_access_cidrs = var.context.cluster_endpoint_public_access_cidrs

  enable_irsa = true

  create_iam_role              = var.context.create_iam_role
  iam_role_arn                 = var.context.iam_role_arn
  iam_role_use_name_prefix     = var.context.iam_role_use_name_prefix
  iam_role_additional_policies = var.context.iam_role_additional_policies

  # Control plane logs
  cluster_enabled_log_types              = var.context.cluster_enabled_log_types
  cloudwatch_log_group_kms_key_id        = var.context.cloudwatch_log_group_kms_key_id
  cloudwatch_log_group_retention_in_days = var.context.cloudwatch_log_group_retention_in_days

  # Security groups
  create_cluster_security_group           = var.context.create_cluster_security_group
  cluster_security_group_id               = var.context.cluster_security_group_id
  cluster_security_group_additional_rules = var.context.cluster_security_group_additional_rules

  # Endpoint config
  cluster_endpoint_private_access = var.context.cluster_endpoint_private_access
  cluster_endpoint_public_access  = var.context.cluster_endpoint_public_access

  # secret encryption
  create_kms_key         = var.context.enable_secrets_encryption && var.context.etcd_kms_arn == null
  kms_key_administrators = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
  cluster_encryption_config = {
    provider_key_arn = var.context.etcd_kms_arn # will be ignored if create_kms_key == true
    resources        = ["secrets"]
  }

  # Managed Node Groups
  eks_managed_node_group_defaults      = local.node_groups_defaults
  eks_managed_node_groups              = var.context.eks_node_groups
  create_node_security_group           = var.context.create_node_security_group
  node_security_group_id               = var.context.node_security_group_id
  node_security_group_additional_rules = var.context.node_security_group_additional_rules

  # Kube auth
  # https://aws.amazon.com/about-aws/whats-new/2023/12/amazon-eks-controls-iam-cluster-access-management/
  # https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/examples/eks_managed_node_group/main.tf#L246
  enable_cluster_creator_admin_permissions = var.context.enable_cluster_creator_admin_permissions
  access_entries                           = var.context.access_entries

  # Tagging
  tags = merge({
    CostCenter = "EKS"
  }, var.context.tags)
}

################################################################################
# Tags for the ASG to support cluster-autoscaler scale up from 0
################################################################################

locals {
  cluster_autoscaler_label_tags = merge([
    for name, group in module.eks.eks_managed_node_groups : {
      for label_name, label_value in coalesce(group.node_group_labels, {}) : "${name}|label|${label_name}" => {
        autoscaling_group = group.node_group_autoscaling_group_names[0],
        key               = "k8s.io/cluster-autoscaler/node-template/label/${label_name}",
        value             = label_value,
      }
    }
  ]...)

  cluster_autoscaler_taint_tags = merge([
    for name, group in module.eks.eks_managed_node_groups : {
      for taint in coalesce(group.node_group_taints, []) : "${name}|taint|${taint.key}" => {
        autoscaling_group = group.node_group_autoscaling_group_names[0],
        key               = "k8s.io/cluster-autoscaler/node-template/taint/${taint.key}:${taint.value}"
        value             = "${taint.effect}"
      }
    }
  ]...)

  cluster_autoscaler_asg_tags = merge(local.cluster_autoscaler_label_tags, local.cluster_autoscaler_taint_tags)
}

resource "aws_autoscaling_group_tag" "these" {
  for_each = local.cluster_autoscaler_asg_tags

  autoscaling_group_name = each.value.autoscaling_group

  tag {
    key   = each.value.key
    value = each.value.value

    propagate_at_launch = false
  }
}

locals {
  node_groups_defaults = merge({

    # Force to true to create a launch template to add worker security group to nodes
    create_launch_template = true
    },
    var.context.node_group_iam_role_arn == null ? {} : { iam_role_arn = var.context.node_group_iam_role_arn },
    var.context.node_group_ami_id == null ? {} : { ami_id = var.context.node_group_ami_id },
    var.context.node_group_ami_type == null ? {} : { ami_type = var.context.node_group_ami_type },
    var.context.custom_node_group_defaults
  )
}
