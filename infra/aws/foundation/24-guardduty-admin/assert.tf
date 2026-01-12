data "aws_caller_identity" "current" {}

resource "terraform_data" "assert_mgmt" {
  lifecycle {
    precondition {
      condition     = data.aws_caller_identity.current.account_id == local.management_account_id
      error_message = "This stack must be applied from the management account profile (AWS_PROFILE=default)."
    }
  }
}
