

# Set up Helm provider with the same configuration



# AWS Load Balancer Controller Helm Release
# used for managing AWS Load Balancer Controller in EKS 

# https://github.com/kubernetes-sigs/aws-load-balancer-controller

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
  namespace  = "istio-system"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  version    = "1.26.3"

  depends_on = [ kubernetes_namespace.istio-system ]
}

resource "helm_release" "istiod" {
  name       = "istiod"
  namespace  = "istio-system"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  version    = "1.26.3"

  # values = [
  #   file("${path.module}/istiod-values.yaml")
  # ]

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
  ]

  depends_on = [helm_release.istio-base]
}






resource "helm_release" "gateways" {
  name       = "gateway"
  namespace  = "istio-gateways"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"
  version    = "1.26.3"

  set = [
    {
      name = "nodeSelector.eks\\.amazonaws\\.com/nodegroup"
      value = split(":", module.eks.eks_managed_node_groups["gateways"].node_group_id)[1]
    }
  ]

  depends_on = [helm_release.istiod, kubernetes_namespace.istio-gateways]
}

# for the new Gateway API support (future work)
resource "null_resource" "gateway_api_crds" {
  provisioner "local-exec" {
    command = "kubectl kustomize -n istio-gateways 'github.com/kubernetes-sigs/gateway-api/config/crd?ref=v1.3.0' | kubectl apply -f -"
  }
}

resource "helm_release" "different-gateways" {
  name       = "gateway-v2"
  namespace  = "istio-gateways"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"
  version    = "1.26.3"

  set = [
    {
      name = "nodeSelector.eks\\.amazonaws\\.com/nodegroup"
      value = split(":", module.eks.eks_managed_node_groups["gateways"].node_group_id)[1]
    }
  ]

  depends_on = [helm_release.istiod, kubernetes_namespace.istio-gateways]
}


# route53 record for Istio Ingress Gateway

# # Get the Istio Ingress Gateway service to fetch the NLB DNS name
# data "kubernetes_service" "istio_gateway" {
#   metadata {
#     name      = "istio-ingressgateway"
#     namespace = "istio-system"
#   }
# }

# # Data source to fetch the AWS NLB created for Istio Ingress Gateway
# data "aws_lb" "istio_nlb" {
#   name = data.kubernetes_service.istio_gateway.status.0.load_balancer.0.ingress.0.hostname
# }

# # Create a Route 53 record for the NLB DNS name
# resource "aws_route53_record" "istio_gateway_record" {
#   zone_id = "YOUR_ROUTE53_ZONE_ID"  # Replace with your hosted zone ID
#   name    = "istio-gateway.example.com"  # Replace with your desired DNS name
#   type    = "A"
#   alias {
#     name                   = data.aws_lb.istio_nlb.dns_name
#     zone_id                = data.aws_lb.istio_nlb.zone_id
#     evaluate_target_health = true
#   }
# }

# output "nlb_dns_name" {
#   value = data.aws_lb.istio_nlb.dns_name
# }