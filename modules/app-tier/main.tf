# User data script for application servers
locals {
  user_data = <<-EOF
              #!/bin/bash
              sudo yum install mariadb -y
              EOF
}

resource "aws_launch_template" "app-tier_launch_template" {
  name_prefix = "${var.project_name}-app-tier-laucnh-template"
  description = "laucnh template for application tier instances"
  image_id = var.ami_id
  instance_type = var.instance_type
  key_name = var.key_pair_name

  vpc_security_group_ids = [var.app_security_group_id]
  user_data = base64encode(local.user_data)
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}app-server-instance"
    }
  }
  tags = {
    Name = "${var.project_name}-app-laumch-template"
  }
}

# Target Group for Application Servers
resource "aws_lb_target_group" "app_tier_tg" {
  name     = "${var.project_name}-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  tags = {
    Name = "${var.project_name}-app-target-group"
  }
}

resource "aws_lb" "app-tier-lb" {
    name = "${var.project_name}-app-tier-lb"
    internal = true
    load_balancer_type = "application"
    security_groups = [var.app_security_group_id]
    subnets = [var.private_subnet_app_tier_1_id, var.private_subnet_app_tier_2_id]
    tags = {
      Name = "${var.project_name}-app-tier-lb"
    }
    enable_deletion_protection = false
}

# Listener for internal LB
resource "aws_lb_listener" "app_ilb_listener" {
  load_balancer_arn = aws_lb.app-tier-lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tier_tg.arn
  }
}

# Auto Scaling Group for application servers
resource "aws_autoscaling_group" "app_asg" {
    name = "${var.project_name}-app-sg"
    max_size            = var.max_size
    min_size            = var.min_size
    desired_capacity    = var.desired_capacity
    target_group_arns = [aws_lb_target_group.app_tier_tg.arn]
    vpc_zone_identifier = [
    var.private_subnet_app_tier_1_id,
    var.private_subnet_app_tier_1_id
    ]
    launch_template {
    id      = aws_launch_template.app-tier_launch_template.id
    version = "$Latest"
    }
    tag {
    key                 = "Name"
    value               = "${var.project_name}-app-tier-asg-instances"
    propagate_at_launch = true
    }
    lifecycle {
    create_before_destroy = true
    }
}

#Auto Scaling Policy based on CPU utilization
resource "aws_autoscaling_policy" "app_cpu_policy" {
  name                   = "${var.project_name}app-tier-cpu-policy"
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value =var.cpu_target_value
  }
}

# ============================================
# BASTION HOST
# ============================================

# Bastion Host Instance
resource "aws_instance" "bastion_host" {
  ami                    = var.ami_id
  instance_type          = var.bastion_instance_type
  key_name               = var.key_pair_name
  subnet_id              = var.public_subnet_1_id
  vpc_security_group_ids = [var.bastion_security_group_id]
  tags = {
    Name = "bastion-host"
  }
  associate_public_ip_address = true
}