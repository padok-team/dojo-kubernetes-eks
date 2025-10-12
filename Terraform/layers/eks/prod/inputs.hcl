
inputs = {
  context = {
    argocd_image_updater_enable = false

    eks_node_groups = {

      # A node pool for my application
      # I override global settings from module.hcl
      # With a specific setting for this env
      app = {
        desired_size   = 1
        max_size       = 6
        min_size       = 1
        instance_types = ["m5a.large"]
        capacity_type  = "ON_DEMAND"
      }
    }
  }
}
