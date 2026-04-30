variable "env" {
  type = string
}

variable "vpc_cidr" {
  type = string
}


variable "cidr_block_public_subnets" {
  type = map(string)
}

variable "availability_zone_subnet_public" {
  type = map(string)
}

variable "availability_zone_subnet_private" {
  type = map(string)
}


variable "cidr_block_private_subnets" {
  type = map(string)
}


