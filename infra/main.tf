module "vpc" {
  source = "./modules/vpc"

  env      = var.env
  vpc_cidr = var.vpc_cidr

  cidr_block_public_subnets       = var.cidr_block_public_subnets
  availability_zone_subnet_public = var.availability_zone_subnet_public

  cidr_block_private_subnets       = var.cidr_block_private_subnets
  availability_zone_subnet_private = var.availability_zone_subnet_private

  # Ensure IAM policies are fully propagated before creating VPC resources (like Flow Logs)
  depends_on = [module.iam]
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

  # Ensure IAM roles and policies are active before creating the EKS cluster and its KMS keys
  depends_on = [module.iam]
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

  # Node group requires both the EKS cluster to be ready and the node IAM role to be propagated
  depends_on = [module.iam, module.eks]
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

  monitoring_role_arn = module.iam.rds_monitoring_role_arn

  # Database depends on VPC networking, EKS security groups, and IAM monitoring roles
  depends_on = [module.iam]
}
