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
  org_id                = data.terraform_remote_state.org.outputs.org_id
  management_account_id = data.terraform_remote_state.org.outputs.management_account_id
}
