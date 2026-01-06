resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = "3.12.2"

  values = [
    yamlencode({
      "args[0]" = "--kubelet-preferred-address-types=InternalIP,Hostname,ExternalIP"
      "args[1]" = "--kubelet-insecure-tls"
    })
  ]
}
