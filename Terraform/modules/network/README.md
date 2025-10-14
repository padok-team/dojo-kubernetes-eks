# AWS Network Terraform module

Terraform module which creates **VPC** resources on **AWS**. This module is an abstraction of the
[AWS VPC Terraform](https://github.com/terraform-aws-modules/terraform-aws-vpc).

## User Stories for this module

- AAOps I can I can deploy an HA VPC on multiple AZ easily
- AAOps I can deploy public, private & intra subnets in my VPC
- AAOps My route tables and NACLs are preconfigured
- AAOps I can retrieve subnets & vpc ids as outputs of the module

## Schema

![Schema](docs/assets/schema.png)

## Usage

```hcl
module "simple_vpc" {
  source = "git@github.com:padok-team/terraform-aws-network.git"

  vpc_name = "Simple_VPC"
  tags = {
    "Scope"      = "Global Tag",
    "Terraform"  = "True",
    "ModuleName" = "simple_vpc"
  }

  public_subnet_tags = {
    "Scope" = "Public Subnet Tag"
  }

  vpc_availability_zone = ["eu-west-3a"]

  vpc_cidr            = "172.16.0.0/24"
  private_subnet_cidr = ["172.16.0.0/25"]
  public_subnet_cidr  = ["172.16.0.128/25"]
  intra_subnet_cidr   = []
}
```

## Examples

- [Example of VPC on 2 AZ with 2 private subnets and 1 NAT](examples/vpc_2_az_2_subnets_1_nat/main.tf)
- [Example of VPC on 2 az, 3 subnets by az and simple NACLs](examples/vpc_2_az_3_subnets/main.tf)

<!-- BEGIN_TF_DOCS -->
## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ssm_bastion"></a> [ssm\_bastion](#module\_ssm\_bastion) | ../bastion-ssm/ | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 5.1.2 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_context"></a> [context](#input\_context) | n/a | <pre>object({<br>    region                = string<br>    vpc_name              = string<br>    vpc_cidr              = string<br>    vpc_availability_zone = list(string)<br><br>    map_public_ip_on_launch = optional(bool, false)<br>    enable_nat_gateway      = optional(bool, false)<br>    single_nat_gateway      = optional(bool, false)<br>    one_nat_gateway_per_az  = optional(bool, true)<br>    create_igw              = optional(bool, true)<br>    tags                    = optional(map(string), {})<br>    vpc_tags                = optional(map(string), {})<br><br>    public_subnets_cidr          = optional(list(string), [])<br>    public_subnet_suffix         = optional(string, "public")<br>    public_dedicated_network_acl = optional(bool, false)<br>    public_inbound_acl_rules     = optional(list(map(string)), [])<br>    public_outbound_acl_rules    = optional(list(map(string)), [])<br>    public_subnet_tags           = optional(map(string), {})<br>    public_acl_tags              = optional(map(string), {})<br><br>    private_subnets_cidr          = optional(list(string), [])<br>    private_subnet_suffix         = optional(string, "private")<br>    private_dedicated_network_acl = optional(bool, false)<br>    private_inbound_acl_rules     = optional(list(map(string)), [])<br>    private_outbound_acl_rules    = optional(list(map(string)), [])<br>    private_subnet_tags           = optional(map(string), {})<br>    private_acl_tags              = optional(map(string), {})<br><br>    intra_subnets_cidr          = optional(list(string), [])<br>    intra_subnet_suffix         = optional(string, "intra")<br>    intra_dedicated_network_acl = optional(bool, false)<br>    intra_inbound_acl_rules     = optional(list(map(string)), [])<br>    intra_outbound_acl_rules    = optional(list(map(string)), [])<br>    intra_subnet_tags           = optional(map(string), {})<br>    intra_acl_tags              = optional(map(string), {})<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_security_group_id"></a> [bastion\_security\_group\_id](#output\_bastion\_security\_group\_id) | The security group ID for the SSM Bastion. |
| <a name="output_this"></a> [this](#output\_this) | VPC Object. |
<!-- END_TF_DOCS -->

## License

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

See [LICENSE](LICENSE) for full details.

```text
Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements.  See the NOTICE file
distributed with this work for additional information
regarding copyright ownership.  The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at

  https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.
```
