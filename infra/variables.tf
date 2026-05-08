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

### variables for database
variable "db_password" {
  description = "MySQL database password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "admin"
}

variable "instance_class" {
  description = "RDS instance type"
  type        = string
  default     = "db.t3.small"
}

variable "allocated_storage" {
  description = "Initial DB storage (GB)"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum DB storage (autoscaling)"
  type        = number
  default     = 50
}
