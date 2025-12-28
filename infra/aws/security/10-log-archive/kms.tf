data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_kms_key" "cloudtrail" {
  description             = "KMS key for CloudTrail logs (org trail)"
  enable_key_rotation     = true
  deletion_window_in_days = 14

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowAccountAdmins"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
        Action    = "kms:*"
        Resource  = "*"
      },
      {
        Sid       = "AllowCloudTrailUseOfTheKey"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action = [
          "kms:GenerateDataKey*",
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id,
            "kms:ViaService"    = "cloudtrail.${data.aws_region.current.id}.amazonaws.com"
          },
          StringLike = {
            "kms:EncryptionContext:aws:cloudtrail:arn" = "arn:aws:cloudtrail*:${local.org_id}:trail/${var.trail_name}"
          }
        }
      }
    ]
  })
}

resource "aws_kms_alias" "cloudtrail" {
  name          = "alias/cloudtrail-org"
  target_key_id = aws_kms_key.cloudtrail.key_id
}
