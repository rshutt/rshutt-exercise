resource "aws_cloudtrail" "org" {
  name                          = var.trail_name
  s3_bucket_name                = aws_s3_bucket.cloudtrail.bucket
  kms_key_id                    = aws_kms_key.cloudtrail.arn
  is_organization_trail         = true
  include_global_service_events = true
  enable_logging                = true
  is_multi_region_trail         = true

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }
}
