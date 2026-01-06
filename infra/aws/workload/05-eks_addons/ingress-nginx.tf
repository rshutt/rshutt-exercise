########################################
# ingress-nginx (NLB)
########################################

resource "kubernetes_namespace_v1" "ingress_nginx" {
  metadata { name = "ingress-nginx" }
}

resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  namespace  = kubernetes_namespace_v1.ingress_nginx.metadata[0].name
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.11.3"

  atomic          = true
  cleanup_on_fail = true
  timeout         = 600

  values = [
    yamlencode({
      controller = {
        service = {
          type = "LoadBalancer"
          annotations = merge(
            {
              "service.beta.kubernetes.io/aws-load-balancer-type"   = "nlb"
              "service.beta.kubernetes.io/aws-load-balancer-scheme" = "internet-facing"
            },
            length(var.nlb_subnet_ids) > 0 ? {
              "service.beta.kubernetes.io/aws-load-balancer-subnets" = join(",", var.nlb_subnet_ids)
            } : {},
            length(var.nlb_eip_allocation_ids) > 0 ? {
              "service.beta.kubernetes.io/aws-load-balancer-eip-allocations" = join(",", var.nlb_eip_allocation_ids)
            } : {}
          )
        }
      }
    })
  ]
}
