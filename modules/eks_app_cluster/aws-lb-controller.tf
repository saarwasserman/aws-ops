
# AWS Load Balancer Controller Helm Release
# used for managing AWS Load Balancer Controller in EKS 

# https://github.com/kubernetes-sigs/aws-load-balancer-controller
resource "helm_release" "lb_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.13.3"

  values = [
    <<-EOF
    clusterName: ${module.eks.cluster_name}
    region: ${var.region}
    vpcId: ${module.vpc.vpc_id}
    serviceAccount.create: false
    serviceAccount.name: aws-load-balancer-controller
    EOF
  ]

  set = [
    {
      name = "controllerConfig.featureGates.NLBGatewayAPI",
      value = "true"
    },
    {
      name = "controllerConfig.featureGates.ALBGatewayAPI",
      value = "true"
    },
    {
      name = "ingressClass",
      value = "nlb"
    }
  ]

  depends_on = [kubernetes_role_binding.aws_lb_controller_role_binding, helm_release.lb_controller_gateway_api, helm_release.istiod]
}


resource "kubernetes_service_account" "aws_lb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "meta.helm.sh/release-name"      = "aws-load-balancer-controller"
      "meta.helm.sh/release-namespace" = "kube-system"
      "eks.amazonaws.com/role-arn" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/eks-lb-controller-role"
    }
    labels = {
      "app.kubernetes.io/managed-by" = "Helm"
    }
  }

  depends_on = [ module.eks ]
}

resource "aws_iam_policy" "lb_controller_policy" {
  name        = "LBControllerPolicy"
  description = "IAM policy for AWS Load Balancer Controller"
  policy = file("iam-policy.json")
}

resource "aws_iam_role" "lb_controller_role" {
  name               = "eks-lb-controller-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.${var.region}.amazonaws.com/id/${local.oidc_id}"
      }
      Condition = {
        StringEquals = {
          "oidc.eks.${var.region}.amazonaws.com/id/${local.oidc_id}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lb_controller_role_policy" {
  policy_arn = aws_iam_policy.lb_controller_policy.arn
  role       = aws_iam_role.lb_controller_role.name
}


resource "kubernetes_role_binding" "aws_lb_controller_role_binding" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "aws-load-balancer-controller"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.aws_lb_controller.metadata[0].name
    namespace = kubernetes_service_account.aws_lb_controller.metadata[0].namespace
  }
}


# K8s Gateway API CRDs

resource "helm_release" "lb_controller_gateway_api" {
  name       = "aws-lb-load-balancer-k8s-gateway-api"
  namespace  = "istio-gateways"
  chart      = "./charts/aws-load-balancer-k8s-gateway-api-crds"

  depends_on = [kubernetes_namespace.istio-gateways]
}
