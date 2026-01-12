resource "aws_ecr_repository" "app" {
  count = var.create_ecr_repo ? 1 : 0
  name  = var.ecr_repo_name
  image_scanning_configuration { scan_on_push = true }
}
