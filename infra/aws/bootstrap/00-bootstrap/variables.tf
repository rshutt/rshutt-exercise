variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "repo_slug" {
  type    = string
  default = "rshutt/rshutt-exercise"
}

variable "state_bucket_name" {
  type        = string
  description = "Globally unique S3 bucket name for Terraform state"
}

variable "tf_ci_role_name" {
  type    = string
  default = "rshutt-exercise-tf-ci"
}

variable "app_ci_role_name" {
  type    = string
  default = "rshutt-exercise-app-ci"
}

variable "create_ecr_repo" {
  type    = bool
  default = true
}

variable "ecr_repo_name" {
  type    = string
  default = "demo-app"
}
