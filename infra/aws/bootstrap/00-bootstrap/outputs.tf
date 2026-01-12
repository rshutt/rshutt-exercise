output "tf_state_bucket" {
  description = "Terraform remote state bucket name"
  value       = aws_s3_bucket.tf_state.bucket
}

output "github_oidc_provider_arn" {
  description = "GitHub Actions OIDC provider ARN"
  value       = aws_iam_openid_connect_provider.github.arn
}

output "aws_tf_role_arn" {
  description = "IAM role assumed by Terraform CI via OIDC"
  value       = aws_iam_role.tf_ci.arn
}

output "aws_app_role_arn" {
  description = "IAM role assumed by App CI via OIDC"
  value       = aws_iam_role.app_ci.arn
}

output "ecr_repository_url" {
  description = "ECR repository URL for the application"
  value       = try(aws_ecr_repository.app[0].repository_url, null)
}
