# DB Subnet Group
resource "aws_db_subnet_group" "this" {
  name       = "${var.env}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "${var.env}-db-subnet-group"
    Environment = var.env
  }
}

# Security Group for MySQL
resource "aws_security_group" "db" {
  name        = "${var.env}-mysql-sg"
  description = "Allow MySQL access from EKS cluster"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL access from EKS"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.eks_sg_id]
  }

  # Recommended egress rule (unrestricted outbound traffic)
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.env}-mysql-sg"
    Environment = var.env
  }
}

# KMS Key for RDS encryption
resource "aws_kms_key" "rds" {
  description             = "KMS key used to encrypt RDS resources"
  enable_key_rotation     = true
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "rds" {
  name          = "alias/${var.env}-rds"
  target_key_id = aws_kms_key.rds.key_id
}

# RDS MySQL Instance
resource "aws_db_instance" "mysql" {
  identifier = "${var.env}-mysql-db"

  # Engine configuration
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = var.instance_class

  # Storage configuration
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  # Database credentials
  db_name  = var.db_name
  username = var.username
  password = var.password

  # Networking
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible    = false

  # High availability
  multi_az = var.multi_az

  # Backup configuration
  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  # Deletion protection & snapshots
  deletion_protection       = true
  skip_final_snapshot       = false
  final_snapshot_identifier = "${var.env}-mysql-final-snapshot"

  # Logging & monitoring
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]
  monitoring_interval             = 60
  performance_insights_enabled    = true
  performance_insights_kms_key_id = aws_kms_key.rds.arn

  tags = {
    Name        = "${var.env}-mysql-db"
    Environment = var.env
  }
}
