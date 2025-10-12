
inputs = {
  config = {
    vpc_cidr = "10.2.0.0/16"

    public_subnets_cidr = [
      "10.2.0.0/28",
      "10.2.0.16/28"
    ]

    private_subnets_cidr = [
      "10.2.16.0/21",
      "10.2.32.0/21"
    ]
  }
}
