resource "aws_organizations_organization" "this" {
  feature_set = var.org_feature_set

  enabled_policy_types = [
    "SERVICE_CONTROL_POLICY",
  ]

  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "guardduty.amazonaws.com",
    "sso.amazonaws.com"
  ]
}

resource "aws_organizations_account" "security" {
  name      = var.security_account_name
  email     = "${var.admin_email_user}-${var.security_account_name}@${var.account_email_domain}"
  parent_id = aws_organizations_organizational_unit.security.id
}

resource "aws_organizations_account" "log_archive" {
  name      = var.log_archive_account_name
  email     = "${var.admin_email_user}-${var.log_archive_account_name}@${var.account_email_domain}"
  parent_id = aws_organizations_organizational_unit.log_archive.id
}

resource "aws_organizations_account" "workload" {
  name      = var.workload_account_name
  email     = "${var.admin_email_user}-${var.workload_account_name}@${var.account_email_domain}"
  parent_id = aws_organizations_organizational_unit.workload.id
}

resource "aws_organizations_organizational_unit" "security" {
  name      = "Security"
  parent_id = local.root_id
}

resource "aws_organizations_organizational_unit" "log_archive" {
  name      = "Log Archive"
  parent_id = local.root_id
}

resource "aws_organizations_organizational_unit" "workload" {
  name      = "Workload"
  parent_id = local.root_id
}
