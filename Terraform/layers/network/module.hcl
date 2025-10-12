terraform {
  source = "${get_path_to_repo_root()}/modules//network"
}

locals {
  root = read_terragrunt_config(find_in_parent_folders("root.hcl"))
  name = "${local.root.locals.project}-${local.root.locals.environment}"
}

inputs = {
  config = {
    vpc_name              = local.name
    vpc_availability_zone = ["eu-west-3a", "eu-west-3b"]

    vpc_flow_log_enabled                  = true
    vpc_flow_log_max_aggregation_interval = 60
    vpc_flow_log_traffic_type             = "ALL"

    intra_subnet_cidr     = []
    public_subnet_suffix  = "public"
    private_subnet_suffix = "private"
    intra_subnet_suffix   = "intra"

    enable_nat_gateway     = true
    one_nat_gateway_per_az = false

    create_igw = true

    map_public_ip_on_launch = false

    public_dedicated_network_acl  = false
    private_dedicated_network_acl = false
    intra_dedicated_network_acl   = false

    public_inbound_acl_rules = [
      {
        "cidr_block" : "0.0.0.0/0",
        "from_port" : 0,
        "protocol" : "-1",
        "rule_action" : "allow",
        "rule_number" : 100,
        "to_port" : 0
      }
    ]

    public_outbound_acl_rules = [
      {
        "cidr_block" : "0.0.0.0/0",
        "from_port" : 0,
        "protocol" : "-1",
        "rule_action" : "allow",
        "rule_number" : 100,
        "to_port" : 0
      }
    ]

    private_inbound_acl_rules = [
      {
        "cidr_block" : "0.0.0.0/0",
        "from_port" : 0,
        "protocol" : "-1",
        "rule_action" : "allow",
        "rule_number" : 100,
        "to_port" : 0
      }
    ]

    private_outbound_acl_rules = [
      {
        "cidr_block" : "0.0.0.0/0",
        "from_port" : 0,
        "protocol" : "-1",
        "rule_action" : "allow",
        "rule_number" : 100,
        "to_port" : 0
      }
    ]

    intra_inbound_acl_rules = [
      {
        "cidr_block" : "0.0.0.0/0",
        "from_port" : 0,
        "protocol" : "-1",
        "rule_action" : "allow",
        "rule_number" : 100,
        "to_port" : 0
      }
    ]

    intra_outbound_acl_rules = [
      {
        "cidr_block" : "0.0.0.0/0",
        "from_port" : 0,
        "protocol" : "-1",
        "rule_action" : "allow",
        "rule_number" : 100,
        "to_port" : 0
      }
    ]

    # By default have a NATGW on each public subnet
    single_nat_gateway = false

    tags = {
      CostCenter = "Network"
    }

    vpc_tags = {}

    public_subnet_tags  = {}
    private_subnet_tags = {}
    intra_subnet_tags   = {}

    public_acl_tags  = {}
    private_acl_tags = {}
    intra_acl_tags   = {}
  }
}
