module "scp_region_allowlist" {
  source      = "../../modules/scp"
  name        = "region-allowlist"
  description = "Deny API calls outside approved regions (protects security & spend)."
  policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "DenyOutsideApprovedRegions"
      Effect   = "Deny"
      Action   = "*"
      Resource = "*"
      Condition = {
        StringNotEquals = {
          "aws:RequestedRegion" = var.allowed_regions
        }
        # Allow global services that don't use regions the same way
        StringNotLikeIfExists = {
          "aws:PrincipalArn" = [
            "arn:aws:iam::*:role/AWSServiceRoleFor*",
            "arn:aws:iam::*:role/OrganizationAccountAccessRole"
          ]
        }
      }
    }]
  })
}

module "scp_protect_logging" {
  source      = "../../modules/scp"
  name        = "protect-logging"
  description = "Prevent disabling CloudTrail and tampering with log delivery."
  policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyStopOrDeleteCloudTrail"
        Effect = "Deny"
        Action = [
          "cloudtrail:StopLogging",
          "cloudtrail:DeleteTrail",
          "cloudtrail:UpdateTrail"
        ]
        Resource = "*"
      },
      {
        Sid    = "DenyDisablingS3PublicAccessBlock"
        Effect = "Deny"
        Action = [
          "s3:PutAccountPublicAccessBlock",
          "s3:PutBucketPublicAccessBlock",
          "s3:DeleteAccountPublicAccessBlock",
          "s3:DeleteBucketPublicAccessBlock"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach SCPs to the whole org (root). In real life you’d attach to OUs selectively.
resource "aws_organizations_policy_attachment" "attach_region_allowlist_root" {
  policy_id = module.scp_region_allowlist.policy_id
  target_id = aws_organizations_organization.this.roots[0].id
}

resource "aws_organizations_policy_attachment" "attach_protect_logging_root" {
  policy_id = module.scp_protect_logging.policy_id
  target_id = aws_organizations_organization.this.roots[0].id
}
