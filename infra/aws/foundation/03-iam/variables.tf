variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "log_archive_role_name" {
  type        = string
  description = "Name of role created that will be assumed during CI/CD"
  default     = "rshutt-exercise-log-archive-tf"
}
