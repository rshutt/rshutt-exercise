resource "aws_organizations_delegated_administrator" "guardduty" {
  account_id        = data.terraform_remote_state.org.outputs.security_account_id
  service_principal = "guardduty.amazonaws.com"
}
