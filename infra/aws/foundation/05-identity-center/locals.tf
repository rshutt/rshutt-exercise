locals {
  instance_arn      = data.aws_ssoadmin_instances.this.arns[0]
  identity_store_id = data.aws_ssoadmin_instances.this.identity_store_ids[0]

  target_accounts = toset([
    data.terraform_remote_state.org.outputs.management_account_id,
    data.terraform_remote_state.org.outputs.security_account_id,
    data.terraform_remote_state.org.outputs.log_archive_account_id,
  ])
}
