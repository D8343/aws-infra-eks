module "vpc" {
  source = "./modules/vpc"

  env      = var.env
  vpc_cidr = var.vpc_cidr

  cidr_block_public_subnets       = var.cidr_block_public_subnets
  availability_zone_subnet_public = var.availability_zone_subnet_public

  cidr_block_private_subnets       = var.cidr_block_private_subnets
  availability_zone_subnet_private = var.availability_zone_subnet_private
}

module "iam" {
  source = "./modules/iam"

  env = var.env
}

module "eks" {
  source = "./modules/eks"

  env                = var.env
  cluster_role_arn   = module.iam.eks_cluster_role_arn
  private_subnet_ids = module.vpc.private_subnet_ids
}


module "node_group" {
  source = "./modules/node-group"

  env           = var.env
  cluster_name  = module.eks.cluster_name
  node_role_arn = module.iam.eks_node_role_arn

  private_subnet_ids = module.vpc.private_subnet_ids

  desired_size   = var.desired_size
  min_size       = var.min_size
  max_size       = var.max_size
  instance_types = var.instance_types
}

module "database" {
  source = "./modules/database"

  env                = var.env
  private_subnet_ids = module.vpc.private_subnet_ids

  db_name           = var.db_name
  username          = var.db_username
  password          = var.db_password
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage

  vpc_id    = module.vpc.vpc_id
  eks_sg_id = module.eks.cluster_security_group_id
}
