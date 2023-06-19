module "asg" {
  source = "../../cluster/asg-rolling-deploy"

  cluster_name = "hello-world-${var.environment}"
  ami          = var.ami
  user_data = templatefile("${path.module}/user-data.sh", {
    server_port = var.server_port
  })
  enable_autoscaling = var.enable_autoscaling

  max_size      = var.max_size
  min_size      = var.min_size
  instance_type = var.instance_type

  subnet_ids = local.subnet_ids

  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  custom_tags = var.custom_tags
}

module "alb" {
  source     = "../../networking/alb"
  alb_name   = "hello-world-${var.environment}"
  subnet_ids = local.subnet_ids
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = module.alb.alb_http_listener_arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}

resource "aws_lb_target_group" "asg" {

  name = "hello-world-${var.environment}"

  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = local.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}