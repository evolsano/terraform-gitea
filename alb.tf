# Reference the existing ACM certificate by its ARN
#data "aws_acm_certificate" "gitea_alb_cert" {
# domain = "gita-demo.emiring.net"
#  arn = "arn:aws:acm:ap-southeast-1:503561451477:certificate/3fa28755-6e2f-409d-bc87-c568b58aeb42"
#}

data "aws_acm_certificate" "gitea_amz_issued" {
  domain      = "gitea-demo.emiring.net"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

# Create the Application Load Balancer
resource "aws_lb" "cog_alb" {
  name               = "cog-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.cog_sg.id]
  subnets            = [aws_subnet.cog_pub_subnet_1a.id,aws_subnet.cog_pub_subnet_1b.id]
  enable_deletion_protection = false
  idle_timeout       = 60
  enable_http2       = true
  tags = {
    Name = "cog-alb"
  }
}

# Create a target group
resource "aws_lb_target_group" "cog_tg" {
  name     = "cog-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.cog_vpc.id
  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold    = 3
    unhealthy_threshold  = 3
  }
}

# Create a listener for the ALB
resource "aws_lb_listener" "cog_listener_https" {
  load_balancer_arn = aws_lb.cog_alb.arn
  port              = 443
  protocol          = "HTTPS"
#  ssl_policy        = "ELBSecurityPolicy-2016-08" #Default Security Policy
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = data.aws_acm_certificate.gitea_amz_issued.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cog_tg.arn
  }
}

#Redirect HTTP listener with a redirect to HTTPS
resource "aws_lb_listener" "cog_listener_http" {
  load_balancer_arn = aws_lb.cog_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      protocol = "HTTPS"
      port     = "443"
      status_code = "HTTP_301"
    }
  }
}

# Register the instance with the target group
resource "aws_lb_target_group_attachment" "cog_instance_attachment" {
  target_group_arn = aws_lb_target_group.cog_tg.arn
  target_id        = aws_instance.gitea_ec2.id
  port             = 80
}