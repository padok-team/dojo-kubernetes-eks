terraform {
  source = "${get_path_to_repo_root()}/modules//sso"
}

dependency "organization" {
  config_path = "${get_terragrunt_dir()}/../root"
}

inputs = {

  config = {
    identity_store_id = "d-80673bce95"
    sso_instance      = "arn:aws:sso:::instance/ssoins-665633ad48dd6777"

    # create user
    users = {
      "team-aws@padok.tech" = {
        display_name = "Team AWS"
        family_name  = "AWS"
        given_name   = "Team"
      },

      "johnd@padok.fr" = {
        display_name = "John Doe"
        family_name  = "John"
        given_name   = "Doe"
      },

      "johnd2@padok.fr" = {
        display_name = "John Doe 2"
        family_name  = "John"
        given_name   = "Doe"
      }
    }

    # define permission set (link to an AWS policy)
    permission_sets = {
      AdministratorAccess = {
        description      = "Provides full access to AWS services and resources.",
        session_duration = "PT2H",
        managed_policies = [
          "arn:aws:iam::aws:policy/AdministratorAccess",
          "arn:aws:iam::aws:policy/AWSSSODirectoryAdministrator"
        ],
        # Uncomment if you want to use custom IAM policies
        # Policies must exists on the target accounts
        #customer_managed_policies = [
        #  "ReadInstanceTags"
        #]
      },
    }

    # create group and associate user
    groups = {
      "Padok-Ops" = {
        users          = ["team-aws@padok.tech", "johnd@padok.fr", "johnd2@padok.fr"]
        permission_set = ["AdministratorAccess"]

        account_ids = [
          dependency.organization.outputs.root_account_id,
          dependency.organization.outputs.accounts.dev-lib.id,
          dependency.organization.outputs.accounts.preprod-lib.id,
          dependency.organization.outputs.accounts.prod-lib.id,
          dependency.organization.outputs.accounts.tooling.id
        ]
      },
    }
  }
}
