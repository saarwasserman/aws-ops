

variable "domain" {
    description = "the ddomain name that will serve your app"
    type = string
}

variable "region" {
  description = "The AWS region where the resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "kubernetes_version" {
  description = "The version of Kubernetes to use for the EKS cluster"
  type        = string
  default     = "1.33"
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}
