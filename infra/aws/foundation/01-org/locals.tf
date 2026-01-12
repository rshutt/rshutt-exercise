locals {
  root_id = one(aws_organizations_organization.this.roots[*].id)
}
