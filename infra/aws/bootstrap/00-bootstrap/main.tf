#
# ci Roles
#

resource "aws_iam_role" "tf_ci" {
  name               = var.tf_ci_role_name
  assume_role_policy = data.aws_iam_policy_document.github_trust.json
}

resource "aws_iam_role" "app_ci" {
  name               = var.app_ci_role_name
  assume_role_policy = data.aws_iam_policy_document.github_trust.json
}

# Terraform CI policy: backend access + broad permissions for demo
data "aws_iam_policy_document" "tf_ci_policy" {
  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.tf_state.arn]
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.tf_state.arn}/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:*", "eks:*", "iam:*", "kms:*", "logs:*", "s3:*", "dynamodb:*",
      "elasticloadbalancing:*", "autoscaling:*", "route53:*", "acm:*", "sts:*",
      "cloudwatch:*", "events:*", "ssm:*", "ecr:*", "tag:GetResources"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "tf_ci" {
  name   = "${var.tf_ci_role_name}-policy"
  policy = data.aws_iam_policy_document.tf_ci_policy.json
}

resource "aws_iam_role_policy_attachment" "tf_ci_attach" {
  role       = aws_iam_role.tf_ci.name
  policy_arn = aws_iam_policy.tf_ci.arn
}

data "aws_iam_policy_document" "app_ci_policy" {
  statement {
    effect    = "Allow"
    actions   = ["eks:DescribeCluster"]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
      "ecr:DescribeRepositories",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:BatchDeleteImage"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "app_ci" {
  name   = "${var.app_ci_role_name}-policy"
  policy = data.aws_iam_policy_document.app_ci_policy.json
}

resource "aws_iam_role_policy_attachment" "app_ci_attach" {
  role       = aws_iam_role.app_ci.name
  policy_arn = aws_iam_policy.app_ci.arn
}
