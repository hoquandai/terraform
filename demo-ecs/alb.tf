# resource "aws_s3_bucket" "lb_logs" {
#   bucket = "${var.name}-lb-logs1234"
# }

# resource "aws_s3_bucket_policy" "bucket_policy" {
#   bucket = aws_s3_bucket.lb_logs.id
#   policy = file("policies/alb_access_log.json")
# }

resource "aws_alb" "alb" {
  name            = "${var.name}-load-balancer"
  subnets         = [aws_subnet.public.id, aws_subnet.public2.id]
  security_groups = [aws_security_group.alb_sg.id]
  # depends_on      = [aws_s3_bucket.lb_logs]

  # access_logs {
  #   bucket  = aws_s3_bucket.lb_logs.bucket
  #   prefix  = var.name
  #   enabled = true
  # }
}

resource "aws_alb_target_group" "alb_group" {
  name        = "${var.name}-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }
}

# redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "front_end" {
  load_balancer_arn = aws_alb.alb.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.alb_group.id
    type             = "forward"
  }
}
