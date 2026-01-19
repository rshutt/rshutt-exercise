resource "aws_iam_role" "log_archive_tf" {
  name = var.log_archive_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = local.management_tf_role_arn
      }
      Action = "sts:AssumeRole"
    }]
  })
}
