
module "eks_app_cluster" {
  source = "../../../modules/eks_app_cluster"

  domain = "domain.com"
  region = "us-east-1"
  cluster_name = "main_eks_cluster"
}
