terraform {
  source = "${get_path_to_repo_root()}/modules//organization"
}

inputs = {
  context = {
    aws_service_access_principals = [
      "cloudtrail.amazonaws.com",
      "securityhub.amazonaws.com",
      "sso.amazonaws.com",
      "ram.amazonaws.com",
      "reachabilityanalyzer.networkinsights.amazonaws.com",
      "compute-optimizer.amazonaws.com",
      "guardduty.amazonaws.com",
    ]

    enable_ram_sharing = true # Needed for RAM

    feature_set = "ALL" # needed for RAM

    # See #196 for more info
    close_on_delete = false # Close account when deleting

    # role created when account is created
    # ⚠️ If your change this value, adapt bootstrap/roles.sh accordingly
    # ⚠️ This role will be used to create the role that will be used to mange the account
    # ⚠️ This role is only assumable from the root account
    role_name = "Padok-Root"

    enabled_policy_types = [
      "SERVICE_CONTROL_POLICY",
    ]

    organizational_units = [
      "app",
      "tooling",
      "library"
    ]

    accounts = {
      tooling = {
        email = "aws-tooling-2@my-organization.com"
        ou    = "tooling"
      },
      dev-lib = {
        email = "aws-dev-lib-2@my-organization.com"
        ou    = "library"
      }
      preprod-lib = {
        email = "aws-preprod-lib-2@my-organization.com"
        ou    = "library"
      }

      prod-lib = {
        email = "aws-prod-lib-2@my-organization.com"
        ou    = "library"
      }
    }

    guardduty_enabled = false

    guardduty_autoenable_organization_members = "ALL"

    guardduty_mails = [
      "team-aws@padok.fr",
      "team-secops@padok.fr"
    ]

    guardduty_enable_s3_audit_logs          = false
    guardduty_enable_eks_audit_logs         = false
    guardduty_enable_eks_runtime_monitoring = false
    guardduty_enable_ebs_malware_protection = false
    guardduty_enable_rds_login_events       = false
    guardduty_enable_lambda_network_logs    = false

    budget_alerts = [
      # {
      #   name                       = "budget-alert-lib"
      #   amount                     = 1500
      #   alert_threshold_percent    = 95
      #   notification_type          = "FORECASTED"
      #   subscriber_email_addresses = ["team-aws@padok.fr"]
      # }
    ]
  }
}
