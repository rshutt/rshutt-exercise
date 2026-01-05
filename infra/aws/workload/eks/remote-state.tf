data "terraform_remote_state" "org" {
  backend = "s3"
  config = {
    bucket       = "tfstate-bucket-824123790769"
    key          = "aws/bootstrap/15-vpc.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}

locals {
  private_subnet_ids = data.terraform_remote_state.org.outputs.private_subnet_ids
  public_subnet_ids  = data.terraform_remote_state.org.outputs.public_subnet_ids
  vpc_id             = data.terraform_remote_state.org.outputs.vpc_id
}
