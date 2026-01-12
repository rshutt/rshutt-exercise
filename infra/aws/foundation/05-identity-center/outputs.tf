output "identity_center_instance_arn" {
  value = local.instance_arn
}

output "identity_store_id" {
  value = local.identity_store_id
}

output "admins_group_id" {
  value = aws_identitystore_group.admins.group_id
}

output "admin_permission_set_arn" {
  value = aws_ssoadmin_permission_set.admin.arn
}
