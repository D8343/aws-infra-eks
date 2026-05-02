variable "env" {}

variable "private_subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "eks_sg_id" {
  type = string
}

variable "db_name" {}
variable "username" {}

variable "password" {
  sensitive = true
}

variable "instance_class" {
  default = "db.t3.micro"
}

variable "allocated_storage" {
  default = 20
}

variable "max_allocated_storage" {
  default = 50
}

variable "multi_az" {
  description = "Enable Multi-AZ for the RDS instance"
  type        = bool
  default     = false
}
