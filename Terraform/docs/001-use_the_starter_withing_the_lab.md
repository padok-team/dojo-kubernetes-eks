# Use the starters within the Padok AWS Lab Account

This documentation will show you how to use the starter within the Padok Lab AWS Account. Useful to test the starter or develop a new feature.

## Requirements

- An AWS account on the [Padok's AWS Organization](https://d-9c671736e4.awsapps.com/start)
  - If you need an account, ask an adminstrator, like GuillaumeL, BenjaminS
- You should be part of the SSO group padok
- You should have access to the Lab account (check the SSO page)

## Setup AWS credentials

The starter use role chaining from Padok AWS SSO to allow user to connect to the Lab AWS account. You don't need an IAM account. Use the SSO.

Edit `.envrc`file:

- comment the following line

```bash
export AWS_CONFIG_FILE=${PWD}"/.aws_config_file"
```

- uncommunt the following line

```bash
# export AWS_CONFIG_FILE=${PWD}"/.aws_config_file_lab"
```

And, follow these steps:

```bash
direnv allow
aws sso login
```

## Terraform starter

Now, before using Terragrunt, you have to adapt the profile configuration in the file `layers/root.hcl` file. Change the profile name regarding the environment you want to use. For example, if you want to deploy on the `dev` environment, use the profile name `padok_lab` for dev:

```json
  profile = {
    sso     = "root"
    root    = "root"
    hub     = "root"
    dev     = "padok_lab" # This changes
    preprod = "preprod"
    prod    = "prod"
    spoke-1 = "dev"
    spoke-2 = "preprod"
    tooling = "prod"
  }
```

You will need to update the `remote_state`

```hcl
remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "tf-state-${local.project}-${local.region}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.region
    dynamodb_table = "terraform-locks"
    profile        = "padok_lab" # This changes
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}
```

Terragrunt will create the bucket automatically

Now, you are ready to use Terragrunt to test and develop the starter.

## ECS starter

Use the needed profile with `AWS_PROFILE` variable.
