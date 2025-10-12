
locals {
  root = read_terragrunt_config(find_in_parent_folders("root.hcl"))
  name = "${local.root.locals.project}-${local.root.locals.environment}"
}
