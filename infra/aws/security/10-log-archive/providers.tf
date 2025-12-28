terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.home_region

  assume_role {
    role_arn = "arn:aws:iam::${local.log_archive_account_id}:role/OrganizationAccountAccessRole"
  }
}
