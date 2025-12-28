variable "home_region" {
  type    = string
  default = "us-east-1"
}

variable "trail_name" {
  type    = string
  default = "org-trail"
}

variable "log_bucket_name" {
  type = string
}

variable "retention_days" {
  type    = number
  default = 14
}
