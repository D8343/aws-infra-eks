### VPC
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.env}-vpc"
  }
}


### IGW to connect public subnets to internet
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.env}-igw"
  }
}

### Public Subnets 
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.cidr_block_public_subnets["a"]
  availability_zone       = var.availability_zone_subnet_public["a"]
  map_public_ip_on_launch = false

  tags = {
    Name                                   = "${var.env}-public-subnet-a"
    "kubernetes.io/role/elb"               = "1"
    "kubernetes.io/cluster/${var.env}-eks" = "shared"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.cidr_block_public_subnets["b"]
  availability_zone       = var.availability_zone_subnet_public["b"]
  map_public_ip_on_launch = false

  tags = {
    Name                                   = "${var.env}-public-subnet-b"
    "kubernetes.io/role/elb"               = "1"
    "kubernetes.io/cluster/${var.env}-eks" = "shared"
  }
}

### Private Subnets
resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.cidr_block_private_subnets["a"]
  availability_zone       = var.availability_zone_subnet_private["a"]
  map_public_ip_on_launch = false

  tags = {
    Name                                   = "${var.env}-private-subnet-a"
    "kubernetes.io/role/internal-elb"      = "1"
    "kubernetes.io/cluster/${var.env}-eks" = "shared"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.cidr_block_private_subnets["b"]
  availability_zone       = var.availability_zone_subnet_private["b"]
  map_public_ip_on_launch = false

  tags = {
    Name                                   = "${var.env}-private-subnet-b"
    "kubernetes.io/role/internal-elb"      = "1"
    "kubernetes.io/cluster/${var.env}-eks" = "shared"
  }
}


### Public Route tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.env}-public-route-table"
  }
}


resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

### Nat gateway to allow private instances to reach the internet
resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_a.id

  tags = {
    Name = "${var.env}-nat-gateway"
  }

}

### Private Route tables
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }


  tags = {
    Name = "${var.env}-private-route-table"
  }
}

### Associate private subnets to private route table
resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}

### VPC Flow logs
resource "aws_flow_log" "vpc" {
  vpc_id = aws_vpc.this.id

  traffic_type = "ALL"

  log_destination_type = "cloud-watch-logs"

  log_destination = aws_cloudwatch_log_group.vpc.arn
  iam_role_arn    = aws_iam_role.vpc_flow_logs.arn
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_kms_key" "vpc_flow_logs" {
  description         = "KMS key for VPC flow logs encryption"
  enable_key_rotation = true
}

resource "aws_kms_key_policy" "vpc_flow_logs" {
  key_id = aws_kms_key.vpc_flow_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Effect = "Allow"
        Principal = {
          Service = "logs.${data.aws_region.current.id}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ]
        Resource = "*"
        Condition = {
          ArnEquals = {
            "kms:EncryptionContext:aws:logs:arn" : "arn:aws:logs:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:log-group:/aws/vpc/${var.env}/flowlogs"
          }
        }
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "vpc" {
  name              = "/aws/vpc/${var.env}/flowlogs"
  retention_in_days = 7
  kms_key_id        = aws_kms_key.vpc_flow_logs.arn
}

resource "aws_iam_role" "vpc_flow_logs" {
  name = "${var.env}-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "vpc-flow-logs.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "vpc_flow_logs" {
  role = aws_iam_role.vpc_flow_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = [
        aws_cloudwatch_log_group.vpc.arn
      ]
    }]
  })
}
