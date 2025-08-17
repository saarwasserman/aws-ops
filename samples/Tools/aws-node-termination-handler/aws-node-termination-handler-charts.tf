provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "termination_handler" {
  name       = "aws-node-termination-handler"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-node-termination-handler"
  version    = "0.20.0" # Update if needed

  values = [
    yamlencode({
      enableSpotInterruptionDraining  = true
      enableScheduledEventDraining    = true
      enableRebalanceMonitoring       = true
      enableRebalanceDraining         = true
      enableSQSTerminationDraining    = false
      nodeSelector = {
        "kubernetes.io/os" = "linux"
      }
    })
  ]
}