


module "prod" {
    source = "./envs/prod/us-east-1"
}

# sample for future environments

# module "prod" {
#   source = "./modules/prod"
#   count  = terraform.workspace == "prod" ? 1 : 0
# }

# module "staging" {
#   source = "./modules/staging"
#   count  = terraform.workspace == "staging" ? 1 : 0
# }

# module "dev" {
#   source = "./modules/dev"
#   count  = terraform.workspace == "dev" ? 1 : 0
# }

# module "prod_networking" {
#   source = "./modules/prod/networking"
#   count  = terraform.workspace == "prod" ? 1 : 0
# }

# module "prod_compute" {
#   source = "./modules/prod/compute"
#   count  = terraform.workspace == "prod" ? 1 : 0
# }

# module "prod_security" {
#   source = "./modules/prod/security"
#   count  = terraform.workspace == "prod" ? 1 : 0
# }