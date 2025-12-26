variable "home_region" {
  type    = string
  default = "us-east-1"
}

variable "org_feature_set" {
  type    = string
  default = "ALL"
}

variable "allowed_regions" {
  type    = list(string)
  default = ["us-east-1", "us-west-2"]
}

variable "security_account_name" {
  type    = string
  default = "security"
}

variable "log_archive_account_name" {
  type    = string
  default = "log-archive"
}

variable "account_email_domain" {
  type        = string
  description = "Use a domain you control; you can use plus-addressing like you+aws-security@domain.com"
}

variable "aws_profile" {
  type    = string
  default = "org-root"
}

variable "admin_email_user" {
  type    = string
  default = "root"
}
