variable "home_region" {
  type    = string
  default = "us-east-1"
}

variable "aws_profile" {
  type    = string
  default = "org-root"
}

variable "state_bucket_name" {
  type        = string
  description = "Globally-unique S3 bucket name for Terraform state"
}

variable "lock_table_name" {
  type    = string
  default = "terraform-locks"
}
