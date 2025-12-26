output "security_account_id" {
  value = aws_organizations_account.security.id
}

output "log_archive_account_id" {
  value = aws_organizations_account.log_archive.id
}

output "org_id" {
  value = aws_organizations_organization.this.id
}
