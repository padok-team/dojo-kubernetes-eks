# VPC Endpoints to avoid going through the NAT Gateway for traffic that can be kept internal
resource "aws_vpc_endpoint" "this" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${var.context["region"]}.s3"
  vpc_endpoint_type = "Interface"

  subnet_ids = module.vpc.private_subnets

  tags = {
    CostCenter = "Network"
  }
}
