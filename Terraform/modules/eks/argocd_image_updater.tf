# create iam policy and role for argocd image updater

resource "aws_iam_policy" "image_updater" {
  count = var.context.argocd_image_updater_enable ? 1 : 0

  name        = "AmazonECRRepositoryPolicy"
  description = "EKS ECR repository policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "ListImagesInEcrRegistry",
        "Effect" : "Allow",
        "Action" : [
          "ecr:ListImages",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer"
        ],
        "Resource" : var.context.argocd_image_updater_ecr_registry
      },
      {
        "Sid" : "GetAuthorizationToken",
        "Effect" : "Allow",
        "Action" : [
          "ecr:GetAuthorizationToken"
        ],
        "Resource" : "*"
      },
    ]
  })
  tags = {}
}

resource "aws_iam_role" "image_updater" {
  count = var.context.argocd_image_updater_enable ? 1 : 0

  name = "image-updater"

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
            "${module.eks.oidc_provider}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "image_updater" {
  count = var.context.argocd_image_updater_enable ? 1 : 0

  name       = "image-updater"
  roles      = [aws_iam_role.image_updater[0].name]
  policy_arn = aws_iam_policy.image_updater[0].arn
}
