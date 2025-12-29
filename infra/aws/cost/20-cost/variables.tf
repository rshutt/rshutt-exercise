variable "home_region" {
  type    = string
  default = "us-east-1"
}

variable "monthly_budget_usd" {
  type    = number
  default = 50
}

variable "alert_emails" {
  type = list(string)
}
