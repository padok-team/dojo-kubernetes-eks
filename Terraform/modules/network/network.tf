module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.21.0"

  create_vpc = true

  ## VPC
  name = var.config.vpc_name
  cidr = var.config.vpc_cidr

  ## Subnets CIDR
  azs             = var.config.vpc_availability_zone
  private_subnets = var.config.private_subnets_cidr
  public_subnets  = var.config.public_subnets_cidr
  intra_subnets   = var.config.intra_subnets_cidr

  ## Subnet suffix
  public_subnet_suffix  = var.config.public_subnet_suffix
  private_subnet_suffix = var.config.private_subnet_suffix
  intra_subnet_suffix   = var.config.intra_subnet_suffix

  ## Gateway
  enable_nat_gateway     = var.config.enable_nat_gateway
  single_nat_gateway     = var.config.single_nat_gateway
  one_nat_gateway_per_az = var.config.one_nat_gateway_per_az
  create_igw             = var.config.create_igw
  enable_vpn_gateway     = false
  enable_dns_hostnames   = true

  ## Disable AWS default resources
  manage_default_route_table    = false
  manage_default_vpc            = false
  manage_default_network_acl    = false
  manage_default_security_group = false

  ## Enable Public IP and NACLs - disable by default
  map_public_ip_on_launch       = var.config.map_public_ip_on_launch
  public_dedicated_network_acl  = var.config.public_dedicated_network_acl
  private_dedicated_network_acl = var.config.private_dedicated_network_acl
  intra_dedicated_network_acl   = var.config.intra_dedicated_network_acl

  ## Define NACLs
  # Used only if public_dedicated_network_acl is true
  public_inbound_acl_rules  = var.config.public_inbound_acl_rules
  public_outbound_acl_rules = var.config.public_outbound_acl_rules

  # Used only if private_dedicated_network_acl is true
  private_inbound_acl_rules  = var.config.private_inbound_acl_rules
  private_outbound_acl_rules = var.config.private_outbound_acl_rules

  # used only if intra_dedicated_network_acl is true
  intra_inbound_acl_rules  = var.config.intra_inbound_acl_rules
  intra_outbound_acl_rules = var.config.intra_outbound_acl_rules

  public_subnet_tags = merge(
    {
      "Public" = "True"
    },
    var.config.public_subnet_tags,
  )

  private_subnet_tags = merge(
    {
      "Private" = "True"
    },
    var.config.private_subnet_tags,
  )

  intra_subnet_tags = merge(
    {
      "Intra" = "True"
    },
    var.config.intra_subnet_tags,
  )

  ## Tagging
  tags             = var.context.default_tags
  vpc_tags         = var.context.default_tags
  private_acl_tags = var.config.private_acl_tags
  public_acl_tags  = var.config.public_acl_tags
  intra_acl_tags   = var.config.intra_acl_tags
}
