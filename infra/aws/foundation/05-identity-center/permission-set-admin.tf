resource "aws_ssoadmin_permission_set" "admin" {
  instance_arn     = local.instance_arn
  name             = "Admin"
  description      = "Administrator access (home org)"
  session_duration = "PT8H"
}

resource "aws_ssoadmin_managed_policy_attachment" "admin_access" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
