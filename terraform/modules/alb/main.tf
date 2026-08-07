resource "aws_lb" "ALB" {
  name                       = "${var.name_prefix}-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb_sg.id]
  subnets                    = var.public_sub_ids
  enable_deletion_protection = false
}

resource "aws_security_group" "alb_sg" {
  name   = "alb_sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "aws_ecs_target_group" {
  name        = "ecs-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 15
    matcher             = "200"
  }
}
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.ALB.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.aws_ecs_target_group.arn
  }
  lifecycle {
  ignore_changes = [
    default_action
  ]
}
}
