terraform {
  backend "s3" {
    bucket       = "tfstate-bucket-824123790769"
    key          = "aws/foundation/01-org.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
