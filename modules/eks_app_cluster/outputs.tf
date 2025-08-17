
data "aws_caller_identity" "current" {}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_ca_certificate" {
  value = module.eks.cluster_certificate_authority_data
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_id" {
  value = module.eks.cluster_id
}

output "cluster_auth" {
  value = module.eks.cluster_name
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}
output "cluster_oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}

output "gateways_node_group_name" {
  value = module.eks.eks_managed_node_groups_autoscaling_group_names[0]
}
