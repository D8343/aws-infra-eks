variable "env" {
  type = string
}

variable "cluster_role_arn" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}
