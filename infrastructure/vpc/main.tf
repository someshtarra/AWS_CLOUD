# ==============================================================================
# Enterprise AWS Three-Tier Architecture - VPC & Networking Module
# Production VPC: 3tier-vpc (10.20.0.0/16) | Region: us-east-1
# Application: Mindcircuit Book Store | Author: Tarra Someswararao
# ==============================================================================

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

provider "aws" {
  region = var.aws_region
}

# Production VPC Definition (3tier-vpc)
resource "aws_vpc" "main" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "3tier-vpc"
    Environment = "production"
    Owner       = "Tarra Someswararao"
    ManagedBy   = "Terraform"
  }
}

# Internet Gateway (3tier-igw)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "3tier-igw"
  }
}

# ------------------------------------------------------------------------------
# Subnet Partitioning Across Availability Zones us-east-1a & us-east-1b
# ------------------------------------------------------------------------------

# Public Subnets (ALB & NAT Gateway Ingress/Egress)
resource "aws_subnet" "pub_sn_1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.20.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "pub-sn-1a"
    Tier = "Public"
  }
}

resource "aws_subnet" "pub_sn_2b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.20.2.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true

  tags = {
    Name = "pub-sn-2b"
    Tier = "Public"
  }
}

# Presentation & Application Tier Private Subnets
resource "aws_subnet" "pvt_sn_3a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.20.3.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "pvt-sn-3a"
    Tier = "Private Application"
  }
}

resource "aws_subnet" "pvt_sn_4b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.20.4.0/24"
  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "pvt-sn-4b"
    Tier = "Private Application"
  }
}

# Database Tier Private Subnets
resource "aws_subnet" "pvt_sn_5a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.20.5.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "pvt-sn-5a"
    Tier = "Private Database"
  }
}

resource "aws_subnet" "pvt_sn_6b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.20.6.0/24"
  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "pvt-sn-6b"
    Tier = "Private Database"
  }
}

# Auxiliary Tier Private Subnets
resource "aws_subnet" "pvt_sn_7a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.20.7.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "pvt-sn-7a"
    Tier = "Private Auxiliary"
  }
}

resource "aws_subnet" "pvt_sn_8b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.20.8.0/24"
  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "pvt-sn-8b"
    Tier = "Private Auxiliary"
  }
}

# ------------------------------------------------------------------------------
# Egress Gateway & Route Tables Configuration
# ------------------------------------------------------------------------------

# Elastic EIP for Managed NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags   = { Name = "3tier-NAT-EIP" }
}

# Multi-AZ Managed NAT Gateway (3tier-NAT in pub-sn-1a)
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.pub_sn_1a.id

  tags = {
    Name = "3tier-NAT"
  }
}

# Public Route Table (3tier-pub-rt -> IGW)
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "3tier-pub-rt"
  }
}

# Private Route Table (3tier-pvt-rt -> NAT)
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "3tier-pvt-rt"
  }
}

# Route Table Associations
resource "aws_route_table_association" "pub_1a" {
  subnet_id      = aws_subnet.pub_sn_1a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "pub_2b" {
  subnet_id      = aws_subnet.pub_sn_2b.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "pvt_3a" {
  subnet_id      = aws_subnet.pvt_sn_3a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "pvt_4b" {
  subnet_id      = aws_subnet.pvt_sn_4b.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "pvt_5a" {
  subnet_id      = aws_subnet.pvt_sn_5a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "pvt_6b" {
  subnet_id      = aws_subnet.pvt_sn_6b.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "pvt_7a" {
  subnet_id      = aws_subnet.pvt_sn_7a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "pvt_8b" {
  subnet_id      = aws_subnet.pvt_sn_8b.id
  route_table_id = aws_route_table.private_rt.id
}
