data "terraform_remote_state" "org" {
  backend = "s3"
  config = {
    bucket       = "tfstate-bucket-824123790769"
    key          = "aws/org/00-org.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}

locals {
  org_id                 = data.terraform_remote_state.org.outputs.org_id
  log_archive_account_id = data.terraform_remote_state.org.outputs.log_archive_account_id
  management_account_id  = data.terraform_remote_state.org.outputs.management_account_id
  trail_arn              = "arn:aws:cloudtrail:us-east-1:${local.management_account_id}:trail/${var.trail_name}"
}
