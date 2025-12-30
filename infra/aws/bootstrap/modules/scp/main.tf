variable "name" { type = string }
variable "description" { type = string }
variable "policy_json" { type = string }

resource "aws_organizations_policy" "this" {
  name        = var.name
  description = var.description
  type        = "SERVICE_CONTROL_POLICY"
  content     = var.policy_json
}

output "policy_id" {
  value = aws_organizations_policy.this.id
}
