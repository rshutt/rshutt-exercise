output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "cluster_oidc_issuer" {
  value = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.eks.arn
}

output "vpc_config" {
  value = aws_eks_cluster.this.vpc_config
}

output "region" {
  value = var.region
}

output "cluster_ca_certificate" {
  description = "Base64-encoded cluster CA data for kube/helm providers"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}
