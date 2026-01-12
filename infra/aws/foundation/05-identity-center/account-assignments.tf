resource "aws_ssoadmin_account_assignment" "admin_group_everywhere" {
  for_each = local.target_accounts

  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn

  principal_type = "GROUP"
  principal_id   = aws_identitystore_group.admins.group_id

  target_type = "AWS_ACCOUNT"
  target_id   = each.value
}
