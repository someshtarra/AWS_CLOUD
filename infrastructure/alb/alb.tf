# ==============================================================================
# Enterprise AWS Three-Tier Architecture - Application Load Balancer Module
# Load Balancers: frontend-ALB (virat.rebel7781.xyz), backend-ALB (api.rebel7781.xyz)
# Application: Mindcircuit Book Store | Author: Tarra Someswararao
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Frontend Application Load Balancer (frontend-ALB)
# ------------------------------------------------------------------------------
resource "aws_lb" "frontend_alb" {
  name               = "frontend-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.frontend_alb_sg_id]
  subnets            = [var.pub_sn_1a_id, var.pub_sn_2b_id]

  enable_deletion_protection = false

  tags = {
    Name        = "frontend-ALB"
    Environment = "production"
  }
}

resource "aws_lb_target_group" "frontend_tg" {
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
  name               = "backend-ALB"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [var.backend_alb_sg_id]
  subnets            = [var.pvt_sn_3a_id, var.pvt_sn_4b_id]

  enable_deletion_protection = false

  tags = {
    Name        = "backend-ALB"
    Environment = "production"
  }
}

resource "aws_lb_target_group" "backend_tg" {
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
  load_balancer_arn = aws_lb.backend_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
}
