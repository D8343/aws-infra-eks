variable "env" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "node_role_arn" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "desired_size" {
  type        = number
  description = "The number of instances that should be running in the group"
}

variable "min_size" {
  type        = number
  description = "The minimum number of instances that should be running in the group"
}

variable "max_size" {
  type        = number
  description = "The maximum number of instances that should be running in the group"
}

variable "instance_types" {
  type        = list(string)
  description = "The instance types to use"
}
