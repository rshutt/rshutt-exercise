data "aws_organizations_organization" "management" {}

resource "aws_s3_bucket" "tf_state" {
  bucket = var.state_bucket_name
}

resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_public_access_block" "tf_state" {
  bucket                  = aws_s3_bucket.tf_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

data "aws_iam_policy_document" "tfstate_bucket" {
  statement {
    sid    = "AllowOrgToListBucket"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]

    resources = ["arn:aws:s3:::tfstate-bucket-824123790769"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = [data.aws_organizations_organization.management.id]
    }
  }

  statement {
    sid    = "AllowOrgToAccessBucket"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]

    resources = ["arn:aws:s3:::tfstate-bucket-824123790769/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = [data.aws_organizations_organization.management.id]
    }
  }
}

resource "aws_s3_bucket_policy" "tfstate_bucket" {
  bucket = aws_s3_bucket.tf_state.id
  policy = data.aws_iam_policy_document.tfstate_bucket.json
}
