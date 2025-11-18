# user data script to install Apache web server
locals {
  user_data = <<-EOF
            #!/bin/bash

            #install apache
            sudo yum -y install httpd

            #enable and start apache
            sudo systemctl enable httpd
            sudo systemctl start httpd

            sudo echo '<!DOCTYPE html>

            <html lang="en">
              <head>
                <meta charset="utf-8" />
                <meta name="viewport" content="width=device-width, initial-scale=1" />

                <title>A Basic HTML5 Template</title>

                <link rel="preconnect" href="https://fonts.googleapis.com" />
                <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
                <link
                  href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;700;800&display=swap"
                  rel="stylesheet"
                />

                <link rel="stylesheet" href="css/styles.css?v=1.0" />
              </head>

              <body>
                <div class="wrapper">
                  <div class="container">
                    <h1>Welcome! An Apache web server has been started successfully.</h1>
                    <p>Replace this with your own index.html file in /var/www/html.</p>
                  </div>
                </div>
              </body>
            </html>

            <style>
              body {
                background-color: #34333d;
                display: flex;
                align-items: center;
                justify-content: center;
                font-family: Inter;
                padding-top: 128px;
              }

              .container {
                box-sizing: border-box;
                width: 741px;
                height: 449px;
                display: flex;
                flex-direction: column;
                justify-content: center;
                align-items: flex-start;
                padding: 48px 48px 48px 48px;
                box-shadow: 0px 1px 32px 11px rgba(38, 37, 44, 0.49);
                background-color: #5d5b6b;
                overflow: hidden;
                align-content: flex-start;
                flex-wrap: nowrap;
                gap: 24;
                border-radius: 24px;
              }

              .container h1 {
                flex-shrink: 0;
                width: 100%;
                height: auto; /* 144px */
                position: relative;
                color: #ffffff;
                line-height: 1.2;
                font-size: 40px;
              }
              .container p {
                position: relative;
                color: #ffffff;
                line-height: 1.2;
                font-size: 18px;
              }
            </style>
            ' > /var/www/html/index.html
              EOF

}

resource "aws_launch_template" "web_launch_template" {
  name_prefix            = "${var.project_name}-web-tier-lauch-template"
  description            = "Launch template for web server instances"
  image_id               = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_pair_name
  vpc_security_group_ids = [var.web_security_group_id]
  user_data              = base64encode(local.user_data)
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-web-tier-instances"
    }
  }
  tags = {
    Name = "${var.project_name}-web-tier-launch-template"
  }
}

resource "aws_lb_target_group" "web_tg" {
  name     = "${var.project_name}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  tags = {
    Name = "${var.project_name}-load-balancer-target-group"
  }
}

resource "aws_lb" "web_alb" {
  name               = "${var.project_name}-web-tier-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.web_security_group_id]
  subnets            = [var.public_subnet_1_id, var.public_subnet_2_id]
  tags = {
    Name = "${var.project_name}-load-balancer"
  }
  enable_deletion_protection = false
}

resource "aws_lb_listener" "web_alb_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

resource "aws_autoscaling_group" "web_asg" {
  name                = "${var.project_name}-asg"
  max_size            = var.max_size
  min_size            = var.min_size
  desired_capacity    = var.desired_capacity
  target_group_arns   = [aws_lb_target_group.web_tg.arn]
  vpc_zone_identifier = [var.public_subnet_1_id, var.public_subnet_2_id]
  launch_template {
    id      = aws_launch_template.web_launch_template.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "${var.project_name}-asg-instance"
    propagate_at_launch = true
  }
  lifecycle {
    create_before_destroy = true
  }
}

# Auto scaling policy based on cpu utilization
resource "aws_autoscaling_policy" "cpu_policy" {
  name                   = "cpu-utilization-policy"
  autoscaling_group_name = aws_autoscaling_group.web_asg.name
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.cpu_target_value
  }
}