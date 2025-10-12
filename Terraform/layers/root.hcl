
terragrunt_version_constraint = ">= 0.82.2"
terraform_version_constraint  = ">= 1.12.2"

locals {
  region        = "eu-west-3"
  backup_region = "eu-central-1"
  project       = "padok"
  environment   = basename(get_original_terragrunt_dir())
  profile = {
    sso     = "root"
    root    = "root"
    hub     = "root"
    dev     = "dev"
    preprod = "preprod"
    prod    = "prod"
    spoke-1 = "dev"
    spoke-2 = "preprod"
    tooling = "prod"
  }
  env_profile = local.profile[local.environment]
  root_dir    = get_terragrunt_dir()

  default_tags = {
    Environment = "${local.environment}"
    Owner       = "${local.project}"
    ManagedByTF = "True"
  }
}

inputs = {
  context = {
    region        = local.region
    backup_region = local.backup_region
    env           = local.environment
    project       = local.project
    default_tags  = local.default_tags
  }
}

remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "tf-state-${local.project}-${local.region}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.region
    dynamodb_table = "terraform-locks"
    profile        = "root"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

#  profile = "${local.env_profile}"
#   profile = "${local.env_profile}"

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.region}"

  default_tags {
    tags = ${jsonencode(local.default_tags)}
  }

  profile = "${local.env_profile}"
}

provider "aws" {
  region = "${local.region}"

  default_tags {
    tags = ${jsonencode(local.default_tags)}
  }
  alias = "root"
  profile = "${local.profile["root"]}"
}

provider "aws" {
  region = "${local.backup_region}"
  alias  = "backups"

  default_tags {
    tags = ${jsonencode(local.default_tags)}
  }

  profile = "${local.env_profile}"
}

provider "aws" {
  region = "us-east-1"
  alias  = "cloudfront"

  default_tags {
    tags = ${jsonencode(local.default_tags)}
  }

  profile = "${local.env_profile}"
}
EOF
}

# Configure Terragrunt to automatically store tfstate files in an S3 bucket
