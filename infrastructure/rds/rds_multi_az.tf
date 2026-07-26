# ==============================================================================
# Enterprise AWS Three-Tier Architecture - Amazon RDS Multi-AZ Module
# Instance Identifier: somesh-db-1 | Engine: MySQL 8.0 | DB Subnet Group: project-3tier-sn-group
# Master User: admin | DB Name: test | Private CNAME: book.rds.com
# Author: Tarra Someswararao
# ==============================================================================

# Database Subnet Group (project-3tier-sn-group)
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "project-3tier-sn-group"
  subnet_ids = [var.pvt_sn_5a_id, var.pvt_sn_6b_id]

  tags = {
    Name        = "project-3tier-sn-group"
    Environment = "production"
  }
}

# Relational Database Instance (somesh-db-1)
resource "aws_db_instance" "rds_primary" {
  identifier            = "somesh-db-1"
  allocated_storage     = 20
  max_allocated_storage = 100
  engine                = "mysql"
  engine_version        = "8.0"
  instance_class        = "db.t3.micro"

  db_name  = "test"
  username = "admin"
  password = var.db_password # Defaults to Somesh12345

  multi_az               = true
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [var.db_sg_id]

  storage_encrypted   = true
  skip_final_snapshot = true

  backup_retention_period = 7
  backup_window           = "03:00-04:00"

  tags = {
    Name        = "somesh-db-1"
    Environment = "production"
    Owner       = "Tarra Someswararao"
  }
}

# Route 53 Private Hosted Zone CNAME Record (book.rds.com -> RDS Endpoint)
resource "aws_route53_record" "rds_cname" {
  zone_id = var.private_zone_id
  name    = "book.rds.com"
  type    = "CNAME"
  ttl     = 300
  records = [aws_db_instance.rds_primary.endpoint]
}
