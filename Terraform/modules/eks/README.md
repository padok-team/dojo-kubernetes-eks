# AWS S3 Terraform module

Terraform module which creates **EKS** cluster on **AWS**. This module is an abstraction of the module[terraform-aws-modules/eks/aws](https://github.com/terraform-aws-modules/terraform-aws-modules/eks/aws) by [terraform-aws-modules](https://registry.terraform.io/namespaces/terraform-aws-modules).

## User Stories for this module


## Usage

```hcl
```

## Examples

<!-- BEGIN_TF_DOCS -->
## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | 19.21.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_context"></a> [context](#input\_context) | n/a | <pre>object({<br>    env    = string<br>    region = string<br><br>    # EKS<br>    eks_cluster_name      = string<br>    eks_cluster_version   = string<br>    eks_service_ipv4_cidr = optional(string)<br><br>    # Logging<br>    cluster_enabled_log_types              = optional(list(string), ["api", "audit", "authenticator", "controllerManager", "scheduler"])<br>    cloudwatch_log_group_kms_key_id        = optional(string, "")<br>    cloudwatch_log_group_retention_in_days = optional(number, 90)<br><br>    # Endpoints<br>    cluster_endpoint_public_access       = optional(bool, false)<br>    cluster_endpoint_public_access_cidrs = optional(list(string), ["0.0.0.0/0"])<br>    cluster_endpoint_private_access      = optional(bool, true)<br><br>    # Network<br>    vpc_id                  = string<br>    vpc_private_subnets_ids = optional(list(string), [])<br><br>    # IAM<br>    create_iam_role              = optional(bool, true)<br>    iam_role_arn                 = optional(string)<br>    iam_role_use_name_prefix     = optional(bool, true)<br>    iam_role_additional_policies = optional(map(string), {})<br><br>    # IAM - Cross Region Resources<br>    # Because role & policy have to be uniq<br>    role_suffix   = optional(string, "")<br>    policy_suffix = optional(string, "")<br><br>    # Security groups<br>    create_cluster_security_group           = optional(bool, true)<br>    cluster_security_group_id               = optional(string, "")<br>    cluster_security_group_additional_rules = optional(any, {})<br>    create_node_security_group              = optional(bool, true)<br>    node_security_group_id                  = optional(string, "")<br>    node_security_group_additional_rules    = optional(any, {})<br><br>    # Secret encryption<br>    etcd_kms_arn              = optional(string)<br>    enable_secrets_encryption = optional(bool, true)<br><br>    # Node groups<br>    eks_node_groups            = optional(any, {})<br>    node_group_iam_role_arn    = optional(string)<br>    node_group_ami_id          = optional(string)<br>    node_group_ami_type        = optional(string)<br>    custom_node_group_defaults = optional(any, {})<br><br>    # Kube auth<br>    aws_auth_accounts         = optional(list(string), [])<br>    create_aws_auth_configmap = optional(bool, false)<br>    manage_aws_auth_configmap = optional(bool, false)<br><br>    # Others<br>    aws_auth_roles                    = optional(list(any), [])<br>    tags                              = optional(map(string), {})<br>    external_secrets_arn_identifier   = optional(string, "external-secrets")<br>    external_dns_arn_identifier       = optional(string, "external-dns")<br>    cluster_autoscaler_arn_identifier = optional(string, "cluster-autoscaler-aws-cluster-autoscaler")<br>    argocd_image_updater_enable       = optional(string, false)<br>    cluster_addons                    = optional(any, {})<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_how_to"></a> [how\_to](#output\_how\_to) | n/a |
| <a name="output_node_security_group_id"></a> [node\_security\_group\_id](#output\_node\_security\_group\_id) | The private subnets of the EKS cluster. |
<!-- END_TF_DOCS -->
