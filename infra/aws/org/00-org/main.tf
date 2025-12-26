resource "aws_organizations_organization" "this" {
  feature_set = var.org_feature_set

  enabled_policy_types = [
    "SERVICE_CONTROL_POLICY",
  ]
}

resource "aws_organizations_account" "security" {
  name  = var.security_account_name
  email = "${var.admin_email_user}-${var.security_account_name}@${var.account_email_domain}"
}

resource "aws_organizations_account" "log_archive" {
  name  = var.log_archive_account_name
  email = "${var.admin_email_user}-${var.log_archive_account_name}@${var.account_email_domain}"
}
