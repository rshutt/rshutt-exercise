resource "aws_organizations_delegated_administrator" "cloudtrail" {
  account_id        = aws_organizations_account.log_archive.id
  service_principal = "cloudtrail.amazonaws.com"
}

resource "aws_iam_service_linked_role" "cloudtrail" {
  aws_service_name = "cloudtrail.amazonaws.com"
}
