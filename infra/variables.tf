variable "env" {
  type        = string
  description = "Deployment environment (dev, staging or prod)"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.env)
    error_message = "env must be either dev, staging or prod"
  }
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR"
}

variable "cidr_block_public_subnets" {
  type = map(string)
}

variable "availability_zone_subnet_public" {
  type = map(string)
}

variable "cidr_block_private_subnets" {
  type = map(string)
}

variable "availability_zone_subnet_private" {
  type = map(string)
}

### variables for node group
variable "desired_size" {
  type = number
}

variable "min_size" {
  type = number
}

variable "max_size" {
  type = number
}

variable "instance_types" {
  type = list(string)
}

variable "github_org" {}
variable "github_repo" {}
