# ==============================================================================
# Enterprise AWS Three-Tier Architecture - Auto Scaling Group & Launch Templates
# Launch Templates: frontend-LT (ami-0e826fcb0c13a348), backend-LT (ami-0cf2ba10137800b5a)
# Auto Scaling Groups: FE-ASG, BE-ASG | Author: Tarra Someswararao
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Frontend Launch Template & Auto Scaling Group (frontend-LT / FE-ASG)
# ------------------------------------------------------------------------------
resource "aws_launch_template" "frontend_template" {
  name_prefix   = "frontend-LT-"
  image_id      = "ami-0e826fcb0c13a348" # Golden frontend-AMI
  instance_type = "t3.micro"

  user_data = filebase64("${path.module}/../scripts/user_data_web.sh")

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # Enforce IMDSv2 security (CKV_AWS_79)
    http_put_response_hop_limit = 1
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.frontend_ec2_sg_id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "FE-ASG-node"
      Environment = "production"
    }
  }
}

resource "aws_autoscaling_group" "fe_asg" {
  name                = "FE-ASG"
  vpc_zone_identifier = [var.pvt_sn_3a_id, var.pvt_sn_4b_id]
  target_group_arns   = [var.frontend_target_group_arn]

  min_size         = 1
  max_size         = 3
  desired_capacity = 1

  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.frontend_template.id
    version = "$Latest"
  }
}

# ------------------------------------------------------------------------------
# 2. Backend Launch Template & Auto Scaling Group (backend-LT / BE-ASG)
# ------------------------------------------------------------------------------
resource "aws_launch_template" "backend_template" {
  name_prefix   = "backend-LT-"
  image_id      = "ami-0cf2ba10137800b5a" # Golden backend-AMI
  instance_type = "t3.micro"

  user_data = filebase64("${path.module}/../scripts/user_data_app.sh")

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # Enforce IMDSv2 security (CKV_AWS_79)
    http_put_response_hop_limit = 1
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.backend_ec2_sg_id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "BE-ASG-node"
      Environment = "production"
    }
  }
}

resource "aws_autoscaling_group" "be_asg" {
  name                = "BE-ASG"
  vpc_zone_identifier = [var.pvt_sn_3a_id, var.pvt_sn_4b_id]
  target_group_arns   = [var.backend_target_group_arn]

  min_size         = 1
  max_size         = 3
  desired_capacity = 1

  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.backend_template.id
    version = "$Latest"
  }
}
