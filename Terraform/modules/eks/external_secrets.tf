# create iam policy and role for external secrets
resource "aws_iam_policy" "external_secrets" {
  name        = "AmazonEKSExternalSecretsPolicy${var.context.policy_suffix}"
  description = "EKS External Secrets policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Action" : [
        "secretsmanager:GetResourcePolicy",
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret",
        "secretsmanager:ListSecretVersionIds"
      ],
      "Resource" : [
        "arn:aws:secretsmanager:${var.context.region}:${data.aws_caller_identity.current.account_id}:secret:*"
      ]
    }]
  })
  tags = var.context.tags
}

resource "aws_iam_role" "external_secrets" {
  name        = "external-secrets${var.context.role_suffix}"
  description = "EKS External Secrets Role"

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
            "${module.eks.oidc_provider}:sub" : "system:serviceaccount:external-secrets:${var.context.external_secrets_arn_identifier}"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "external_secrets" {
  name       = "external-secrets"
  roles      = [aws_iam_role.external_secrets.name]
  policy_arn = aws_iam_policy.external_secrets.arn
}
