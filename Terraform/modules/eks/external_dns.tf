# create iam policy and role for external dns

resource "aws_iam_policy" "external_dns" {
  name        = "AmazonEKSExternalDNSPolicy${var.context.policy_suffix}"
  description = "EKS External DNS policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:ChangeResourceRecordSets"
        ],
        "Resource" : [
          "arn:aws:route53:::hostedzone/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets"
        ],
        "Resource" : [
          "*"
        ]
      }
    ]
  })
  tags = var.context.tags
}

resource "aws_iam_role" "external_dns" {
  name        = "external-dns${var.context.role_suffix}"
  description = "EKS External DNS Role"

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
            "${module.eks.oidc_provider}:sub" : "system:serviceaccount:external-dns:${var.context.external_dns_arn_identifier}"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "external_dns" {
  name       = "external-dns"
  roles      = [aws_iam_role.external_dns.name]
  policy_arn = aws_iam_policy.external_dns.arn
}
