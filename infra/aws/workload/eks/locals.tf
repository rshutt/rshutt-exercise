locals {
  tags = merge(
    {
      "managed-by" = "terraform"
      "component"  = "eks"
      "cluster"    = var.name
    },
    var.tags
  )
}
