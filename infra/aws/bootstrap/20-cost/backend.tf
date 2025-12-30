terraform {
  backend "s3" {
    bucket       = "tfstate-bucket-824123790769"
    key          = "aws/bootstrap/20-cost.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
