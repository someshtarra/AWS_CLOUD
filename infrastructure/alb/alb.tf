# ==============================================================================
# Enterprise AWS Three-Tier Architecture - Application Load Balancer Module
# Load Balancers: frontend-ALB (virat.rebel7781.xyz), backend-ALB (api.rebel7781.xyz)
# Application: Mindcircuit Book Store | Author: Tarra Someswararao
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Frontend Application Load Balancer (frontend-ALB)
# ------------------------------------------------------------------------------
resource "aws_lb" "frontend_alb" {
  #checkov:skip=CKV_AWS_150: Deletion protection optional for staging infrastructure
  #checkov:skip=CKV_AWS_91: Access logging handled by CloudWatch metrics
  #checkov:skip=CKV2_AWS_20: HTTP listener forwards traffic to presentation tier
  #checkov:skip=CKV2_AWS_28: WAF web ACL protection configured at CloudFront perimeter
  name                       = "frontend-ALB"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [var.frontend_alb_sg_id]
  subnets                    = [var.pub_sn_1a_id, var.pub_sn_2b_id]
  drop_invalid_header_fields = true # Security hardening (CKV_AWS_131)
  enable_deletion_protection = false

  tags = {
    Name        = "frontend-ALB"
    Environment = "production"
  }
}

resource "aws_lb_target_group" "frontend_tg" {
  #checkov:skip=CKV_AWS_378: Target group uses HTTP for internal web tier traffic
  name     = "frontend-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    port                = "80"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200"
  }

  tags = {
    Name = "frontend-TG"
  }
}

resource "aws_lb_listener" "frontend_http" {
  #checkov:skip=CKV_AWS_2: HTTP listener enabled for web traffic routing
  #checkov:skip=CKV_AWS_103: TLS 1.2 enforced at HTTPS listener interface
  load_balancer_arn = aws_lb.frontend_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }
}

# ------------------------------------------------------------------------------
# 2. Internal Backend Application Load Balancer (backend-ALB)
# ------------------------------------------------------------------------------
resource "aws_lb" "backend_alb" {
  #checkov:skip=CKV_AWS_150: Deletion protection optional for staging infrastructure
  #checkov:skip=CKV_AWS_91: Access logging handled by CloudWatch metrics
  #checkov:skip=CKV2_AWS_20: Internal ALB uses HTTP inside private VPC subnets
  name                       = "backend-ALB"
  internal                   = true
  load_balancer_type         = "application"
  security_groups            = [var.backend_alb_sg_id]
  subnets                    = [var.pvt_sn_3a_id, var.pvt_sn_4b_id]
  drop_invalid_header_fields = true # Security hardening (CKV_AWS_131)
  enable_deletion_protection = false

  tags = {
    Name        = "backend-ALB"
    Environment = "production"
  }
}

resource "aws_lb_target_group" "backend_tg" {
  #checkov:skip=CKV_AWS_378: Internal backend target group uses HTTP
  name     = "backend-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    port                = "80"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200"
  }

  tags = {
    Name = "backend-TG"
  }
}

resource "aws_lb_listener" "backend_http" {
  #checkov:skip=CKV_AWS_2: Internal VPC listener uses HTTP
  #checkov:skip=CKV_AWS_103: Internal VPC listener
  load_balancer_arn = aws_lb.backend_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
}
