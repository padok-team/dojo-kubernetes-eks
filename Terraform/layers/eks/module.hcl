terraform {
  source = "${get_path_to_repo_root()}/modules//eks"
}

locals {
  root = read_terragrunt_config(find_in_parent_folders("root.hcl"))
  name = local.root.locals.project
}

dependency "network" {
  config_path = "${get_terragrunt_dir()}/../../network/${local.root.locals.environment}" # Change name of the network layer depending on the one you are using
}

inputs = {
  context = {
    region = local.root.locals.region

    # EKS
    cluster_name      = local.name
    cluster_version   = "1.29"
    service_ipv4_cidr = "10.42.0.0/16" # default is 10.10.0.0/16

    cluster_addons = {
      coredns = {
        most_recent = true
      }
      kube-proxy = {
        most_recent = true
      }
      vpc-cni = {
        most_recent    = true
        before_compute = true
        configuration_values = jsonencode({
          env = {
            # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
            ENABLE_PREFIX_DELEGATION = "true"
            WARM_PREFIX_TARGET       = "1"
          }
        })
      }
    }

    # Network and security
    vpc_id                  = dependency.network.outputs.this.vpc_id
    vpc_private_subnets_ids = dependency.network.outputs.this.private_subnets

    cluster_security_group_additional_rules = {
      allow_bastion_access_to_eks_api_server = {
        description                = "Allow bastion to access EKS API server"
        protocol                   = "tcp"
        from_port                  = 443
        to_port                    = 443
        type                       = "ingress"
        source_node_security_group = false
        source_security_group_id   = dependency.network.outputs.bastion_security_group_id
      }
    }

    # See the documentation here : https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/network_connectivity.md
    # Or look at the security group with the console : eks-cluster-sg-{cluster-name}
    node_security_group_additional_rules = {

      # An example of an additionnal webhook access from API Server
      # Somes ports are already allowed by defaut
      allow_api_server_to_nodes_on_all_port = {
        description                   = "API Server webhook 7443"
        protocol                      = "tcp"
        from_port                     = 7443
        to_port                       = 7443
        type                          = "ingress"
        source_cluster_security_group = true
      }

      # Extend node-to-node security group rules
      ingress_self_all = {
        description = "Node to node all ports/protocols"
        protocol    = "-1"
        from_port   = 0
        to_port     = 0
        type        = "ingress"
        self        = true
      }
      egress_all = {
        description      = "Node all egress"
        protocol         = "-1"
        from_port        = 0
        to_port          = 0
        type             = "egress"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
      }
    }

    # Node groups
    eks_node_groups = {
      # an node group for my gitlab runner
      # will scale from 0 with autoscaler
      main = {
        desired_size   = 2
        max_size       = 5
        min_size       = 0
        instance_types = ["t3a.medium", "t3.medium"]
        capacity_type  = "ON_DEMAND"
        labels         = { "kubernetes/node-group" = "main" }
      }

      app = {
        desired_size  = 0
        max_size      = 10
        min_size      = 0
        capacity_type = "SPOT" # default capacity, override on each env
        # labels are the same for all env
        labels = { "kubernetes/node-group" = "app" }
        # You can also add taints for node group running specific workloads
        taints = [
          {
            effect = "NO_SCHEDULE"
            key    = "dedicated"
            value  = "app"
          }
        ]

        # global setting for node disk
        block_device_mappings = {
          xvda = {
            device_name = "/dev/xvda"
            ebs = {
              delete_on_termination = true
              encrypted             = true
              volume_size           = 20 # Be careful to adjust this value depending on storage used locally by Pods
              volume_type           = "gp3"
            }
          }
        }
      }
    }
  }
}
