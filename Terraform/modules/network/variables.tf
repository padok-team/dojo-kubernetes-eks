# context like defined in root.hcl with inputs.context
variable "context" {
  type = object({
    region        = string
    backup_region = string
    env           = string
    project       = string
    default_tags  = map(string)
  })
  description = "Context containing region, backup region, environment, project and default tags"
}

variable "config" {
  type = object({

    vpc_name              = string
    vpc_cidr              = string
    vpc_availability_zone = list(string)

    vpc_flow_log_enabled                  = optional(bool, false)
    vpc_flow_log_max_aggregation_interval = optional(number, 60)
    vpc_flow_log_traffic_type             = optional(string, "ALL")

    map_public_ip_on_launch = optional(bool, false)
    enable_nat_gateway      = optional(bool, false)
    single_nat_gateway      = optional(bool, false)
    one_nat_gateway_per_az  = optional(bool, true)
    create_igw              = optional(bool, true)
    tags                    = optional(map(string), {})
    vpc_tags                = optional(map(string), {})

    public_subnets_cidr          = optional(list(string), [])
    public_subnet_suffix         = optional(string, "public")
    public_dedicated_network_acl = optional(bool, false)
    public_inbound_acl_rules     = optional(list(map(string)), [])
    public_outbound_acl_rules    = optional(list(map(string)), [])
    public_subnet_tags           = optional(map(string), {})
    public_acl_tags              = optional(map(string), {})

    private_subnets_cidr          = optional(list(string), [])
    private_subnet_suffix         = optional(string, "private")
    private_dedicated_network_acl = optional(bool, false)
    private_inbound_acl_rules     = optional(list(map(string)), [])
    private_outbound_acl_rules    = optional(list(map(string)), [])
    private_subnet_tags           = optional(map(string), {})
    private_acl_tags              = optional(map(string), {})

    intra_subnets_cidr          = optional(list(string), [])
    intra_subnet_suffix         = optional(string, "intra")
    intra_dedicated_network_acl = optional(bool, false)
    intra_inbound_acl_rules     = optional(list(map(string)), [])
    intra_outbound_acl_rules    = optional(list(map(string)), [])
    intra_subnet_tags           = optional(map(string), {})
    intra_acl_tags              = optional(map(string), {})
  })

  description = "Network configuration values"
}
