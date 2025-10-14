
variable "context" {
  type = object({
    env    = string
    region = string

    # EKS
    cluster_name      = string
    cluster_version   = string
    service_ipv4_cidr = optional(string, "10.10.0.0/16")

    # Karpenter
    enable_karpenter = optional(bool, false)
    cluster_addons   = optional(map(string), {})

    # Logging
    cluster_enabled_log_types              = optional(list(string), ["api", "audit", "authenticator", "controllerManager", "scheduler"])
    cloudwatch_log_group_kms_key_id        = optional(string, "")
    cloudwatch_log_group_retention_in_days = optional(number, 365)

    # Endpoints
    cluster_endpoint_public_access       = optional(bool, false)
    cluster_endpoint_public_access_cidrs = optional(list(string), ["0.0.0.0/0"])
    cluster_endpoint_private_access      = optional(bool, true)

    # Network
    vpc_id                  = string
    vpc_private_subnets_ids = optional(list(string), [])

    # IAM
    create_iam_role              = optional(bool, true)
    iam_role_arn                 = optional(string)
    iam_role_use_name_prefix     = optional(bool, true)
    iam_role_additional_policies = optional(map(string), {})

    # IAM - Cross Region Resources
    # Because role & policy have to be uniq
    role_suffix   = optional(string, "")
    policy_suffix = optional(string, "")

    # Security groups
    create_cluster_security_group           = optional(bool, true)
    cluster_security_group_id               = optional(string, "")
    cluster_security_group_additional_rules = optional(map(string), {})
    create_node_security_group              = optional(bool, true)
    node_security_group_id                  = optional(string, "")
    node_security_group_additional_rules    = optional(map(string), {})

    # Secret encryption
    etcd_kms_arn              = optional(string)
    enable_secrets_encryption = optional(bool, true)

    # Node groups
    eks_node_groups            = optional(map(string), {})
    node_group_iam_role_arn    = optional(string)
    node_group_ami_id          = optional(string)
    node_group_ami_type        = optional(string)
    custom_node_group_defaults = optional(map(string), {})
    ebs_csi_attach             = optional(bool, false)

    # Kube auth
    enable_cluster_creator_admin_permissions = optional(bool, true)
    access_entries                           = optional(map(string), {})
    #aws_auth_accounts         = optional(list(string), [])
    #create_aws_auth_configmap = optional(bool, false)
    #manage_aws_auth_configmap = optional(bool, false)

    # Others
    #aws_auth_roles                    = optional(list(string), [])
    tags                              = optional(map(string), {})
    external_secrets_arn_identifier   = optional(string, "external-secrets")
    external_dns_arn_identifier       = optional(string, "external-dns")
    cluster_autoscaler_arn_identifier = optional(string, "cluster-autoscaler-aws-cluster-autoscaler")
    alb_controller_arn_identifier     = optional(string, "aws-load-balancer-controller")

    argocd_image_updater_enable       = optional(bool, false)
    argocd_image_updater_ecr_registry = optional(string, "")
  })
  description = "values from the context module"
}
