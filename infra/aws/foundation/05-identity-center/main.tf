resource "aws_identitystore_group" "admins" {
  identity_store_id = local.identity_store_id

  display_name = "Admins"
  description  = "Human administrators (IAM Identity Center)"
}

resource "aws_identitystore_user" "primary" {
  identity_store_id = local.identity_store_id

  user_name    = var.idc_user_name
  display_name = "${var.idc_user_given_name} ${var.idc_user_family_name}"

  name {
    given_name  = var.idc_user_given_name
    family_name = var.idc_user_family_name
  }

  emails {
    value   = var.idc_user_email
    primary = true
  }
}

resource "aws_identitystore_group_membership" "primary_admins" {
  identity_store_id = local.identity_store_id
  group_id          = aws_identitystore_group.admins.group_id
  member_id         = aws_identitystore_user.primary.user_id
}
