
resource "kubernetes_namespace" "istio-system" {
  metadata {
    name = "istio-system"
  }
}

resource "kubernetes_namespace" "istio-gateways" {
  metadata {
    name = "istio-gateways"
  }
}

resource "helm_release" "istio-base" {
  name       = "istio-base"
  namespace  = kubernetes_namespace.istio-system.metadata[0].name
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  version    = "1.26.3"
}

resource "helm_release" "istiod" {
  name       = "istiod"
  namespace  = kubernetes_namespace.istio-system.metadata[0].name
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  version    = "1.26.3"

  timeout = "600"

  set = [
    {
      name = "replicaCount"
      value = 1
    },
    {
      name = "autoscaleMin"
      value = 1
    },
    {
      name = "resources.requests.cpu"
      value = "200m"
    },
    {
      name = "resources.requests.memory"
      value = "128Mi"
    },
        {
      name = "meshConfig.accessLogFile"
      value = "/dev/stdout"
    },
  ]

  depends_on = [helm_release.istio-base]
}

resource "helm_release" "gateways" {
  name       = "main-gateway"
  namespace  = kubernetes_namespace.istio-gateways.metadata[0].name
  chart = "./charts/istio-gateway"

  set = [
    {
      name = "nodeGroupName"
      value = split(":", data.aws_eks_node_group.gateways_node_group.id)[1]
    }
  ]

  depends_on = [helm_release.lb_controller]
}





