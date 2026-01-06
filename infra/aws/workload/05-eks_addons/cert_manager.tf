#######################################
# cert-manager + ACME (Route53 DNS-01)
########################################

resource "kubernetes_namespace_v1" "cert_manager" {
  metadata { name = "cert-manager" }
}

# Derive zone name from zone id (Route53 returns trailing dot)
data "aws_route53_zone" "acme_zone" {
  zone_id = var.route53_hosted_public_zone_id
}

locals {
  acme_dns_zone_name = trimsuffix(data.aws_route53_zone.acme_zone.name, ".")
}

resource "aws_iam_role" "cert_manager" {
  name = "${local.cluster_name}-cert-manager"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = local.oidc_provider_arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${local.oidc_provider}:sub" = "system:serviceaccount:cert-manager:cert-manager"
          "${local.oidc_provider}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })
}

resource "aws_iam_policy" "cert_manager" {
  name = "${local.cluster_name}-cert-manager-route53"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["route53:GetChange"]
        Resource = "arn:aws:route53:::change/*"
      },
      {
        Effect   = "Allow"
        Action   = ["route53:ChangeResourceRecordSets"]
        Resource = "arn:aws:route53:::hostedzone/${var.route53_hosted_public_zone_id}"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cert_manager" {
  role       = aws_iam_role.cert_manager.name
  policy_arn = aws_iam_policy.cert_manager.arn
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  namespace  = kubernetes_namespace_v1.cert_manager.metadata[0].name
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.15.3"

  atomic          = true
  cleanup_on_fail = true
  timeout         = 600

  values = [
    yamlencode({
      installCRDs = true

      serviceAccount = {
        create = true
        name   = "cert-manager"
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.cert_manager.arn
        }
      }

      extraObjects = [
        {
          apiVersion = "cert-manager.io/v1"
          kind       = "ClusterIssuer"
          metadata   = { name = "letsencrypt-staging" }
          spec = {
            acme = {
              email               = var.acme_email
              server              = "https://acme-staging-v02.api.letsencrypt.org/directory"
              privateKeySecretRef = { name = "letsencrypt-staging-account-key" }
              solvers = [{
                selector = { dnsZones = [local.route53_zone_name] }
                dns01 = {
                  route53 = {
                    region       = local.region
                    hostedZoneID = var.route53_hosted_public_zone_id
                  }
                }
              }]
            }
          }
        },
        {
          apiVersion = "cert-manager.io/v1"
          kind       = "ClusterIssuer"
          metadata   = { name = "letsencrypt-prod" }
          spec = {
            acme = {
              email               = var.acme_email
              server              = "https://acme-v02.api.letsencrypt.org/directory"
              privateKeySecretRef = { name = "letsencrypt-prod-account-key" }
              solvers = [{
                selector = { dnsZones = [local.route53_zone_name] }
                dns01 = {
                  route53 = {
                    region       = local.region
                    hostedZoneID = var.route53_hosted_public_zone_id
                  }
                }
              }]
            }
          }
        }
      ]
    })
  ]
  depends_on = [aws_iam_role_policy_attachment.cert_manager]
}
