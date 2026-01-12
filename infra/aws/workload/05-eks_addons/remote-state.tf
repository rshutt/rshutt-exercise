data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "tfstate-bucket-824123790769"
    key    = "aws/workload/eks.tfstate"
    region = "us-east-1"
  }
}

locals {
  cluster_name        = data.terraform_remote_state.eks.outputs.cluster_name
  region              = data.terraform_remote_state.eks.outputs.region
  vpc_id              = data.terraform_remote_state.eks.outputs.vpc_config[0].vpc_id
  cluster_oidc_issuer = data.terraform_remote_state.eks.outputs.cluster_oidc_issuer
  oidc_provider_arn   = data.terraform_remote_state.eks.outputs.oidc_provider_arn
  oidc_provider = replace(
    data.terraform_remote_state.eks.outputs.cluster_oidc_issuer,
    "https://",
    ""
  )
}

data "aws_eks_cluster" "this" {
  name = local.cluster_name
}

data "aws_vpc" "this" {
  id = local.vpc_id
}
