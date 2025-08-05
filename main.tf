
module "eks_app_cluster" {
  source = "./modules/eks_app_cluster"  # Relative path to the local module

  domain = "saarw.com"
  region = "us-east-1"
  cluster_name = "main_eks_cluster"
}
