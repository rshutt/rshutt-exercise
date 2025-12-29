output "guardduty_delegated_admin_account_id" {
  value = aws_organizations_delegated_administrator.guardduty.account_id
}
