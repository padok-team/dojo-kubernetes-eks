resource "aws_flow_log" "this" {
  count = var.config.vpc_flow_log_enabled ? 1 : 0

  vpc_id = module.vpc.vpc_id

  iam_role_arn    = aws_iam_role.this[0].arn
  log_destination = aws_cloudwatch_log_group.this[0].arn

  traffic_type             = var.config.vpc_flow_log_traffic_type
  max_aggregation_interval = var.config.vpc_flow_log_max_aggregation_interval
}

resource "aws_cloudwatch_log_group" "this" {
  #checkov:skip=CKV_AWS_158:Ignored
  count = var.config.vpc_flow_log_enabled ? 1 : 0

  name              = "${var.config.vpc_name}-vpc-flow-log"
  retention_in_days = 365
}

data "aws_iam_policy_document" "vpc_flow_log_assume_role" {
  count = var.config.vpc_flow_log_enabled ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "this" {
  count = var.config.vpc_flow_log_enabled ? 1 : 0

  name               = "vpc_flow_log"
  assume_role_policy = data.aws_iam_policy_document.vpc_flow_log_assume_role[0].json
}

data "aws_iam_policy_document" "vpc_flow_log" {
  count = var.config.vpc_flow_log_enabled ? 1 : 0

  # checkov:skip=CKV_AWS_356: Ensure no IAM policies documents allow "*" as a statement's resource for restrictable actions
  # checkov:skip=CKV_AWS_111: Ensure IAM policies does not allow write access without constraints
  statement {
    effect = "Allow"

    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role_policy" "this" {
  count = var.config.vpc_flow_log_enabled ? 1 : 0

  name   = "vpc_flow_log"
  role   = aws_iam_role.this[0].id
  policy = data.aws_iam_policy_document.vpc_flow_log[0].json
}
