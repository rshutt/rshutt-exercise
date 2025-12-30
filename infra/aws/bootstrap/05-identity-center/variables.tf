variable "aws_region" {
  type    = string
  default = "us-east-1"
}

# Identity Center user inputs (so you don't hardcode yourself)
variable "idc_user_name" {
  type = string
}

variable "idc_user_email" {
  type = string
}

variable "idc_user_given_name" {
  type = string
}

variable "idc_user_family_name" {
  type = string
}
