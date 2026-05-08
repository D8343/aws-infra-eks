env = "staging"

### VPC
vpc_cidr = "10.0.0.0/16"

cidr_block_public_subnets = {
  a = "10.0.1.0/24"
  b = "10.0.2.0/24"
}
cidr_block_private_subnets = {
  a = "10.0.101.0/24",
  b = "10.0.102.0/24"
}

availability_zone_subnet_public = {
  a = "eu-west-3a"
  b = "eu-west-3b"
}

availability_zone_subnet_private = {
  a = "eu-west-3a"
  b = "eu-west-3b"
}

### scaling_config - node group
desired_size   = 2
min_size       = 1
max_size       = 3
instance_types = ["t3.medium"]

### RDS
instance_class = "db.t3.small"
