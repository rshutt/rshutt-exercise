data "terraform_remote_state" "org" {
  backend = "s3"
  config = {
    bucket       = "tfstate-bucket-824123790769"
    key          = "aws/org/00-org.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}
