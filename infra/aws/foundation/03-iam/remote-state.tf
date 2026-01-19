data "terraform_remote_state" "org" {
  backend = "s3"
  config = {
    bucket       = "tfstate-bucket-824123790769"
    key          = "aws/foundation/01-org.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}

data "terraform_remote_state" "bootstrap" {
  backend = "s3"
  config = {
    bucket       = "tfstate-bucket-824123790769"
    key          = "aws/bootstrap/00-bootstrap.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}

locals {
  log_archive_account_id = data.terraform_remote_state.org.outputs.log_archive_account_id
  management_tf_role_arn = data.terraform_remote_state.bootstrap.outputs.aws_tf_role_arn
}
