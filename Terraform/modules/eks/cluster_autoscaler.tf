# create iam policy and role for cluster_autoscaler

resource "aws_iam_policy" "cluster_autoscaler" {
  name        = "AmazonEKSClusterAutoscalerPolicy${var.context.policy_suffix}"
  description = "EKS Autoscaler policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplateVersions"
        ],
        "Resource" : ["*"]
      },
      // Theses are write actions, you might want to restrict this permissions
      {
        "Effect" : "Allow",
        "Action" : [
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup"
        ],
        "Resource" : ["*"]
      }
    ]
  })
  tags = var.context.tags
}

resource "aws_iam_role" "cluster_autoscaler" {
  name        = "cluster-autoscaler${var.context.role_suffix}"
  description = "EKS Autoscaler Role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "${module.eks.oidc_provider_arn}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${module.eks.oidc_provider}:sub" : "system:serviceaccount:kube-system:${var.context.cluster_autoscaler_arn_identifier}"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  roles      = [aws_iam_role.cluster_autoscaler.name]
  policy_arn = aws_iam_policy.cluster_autoscaler.arn
}
