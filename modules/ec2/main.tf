variable "public_subnet_id_a" {}
variable "public_subnet_id_b" {}
variable "private_subnet_id" {}
variable "bastion_sg_id" {}
variable "private_sg_id" {}
variable "key_name" {}
variable "vpc_id" {}

resource "aws_instance" "bastion" {
  ami                         = "ami-020cba7c55df1f615"
  instance_type               = "t2.micro"
  subnet_id                   = var.public_subnet_id_a
  key_name                    = var.key_name
  vpc_security_group_ids      = [var.bastion_sg_id]
  associate_public_ip_address = true
  tags = { Name = "bastion-host" }
}

resource "aws_instance" "private_nginx" {
  ami                    = "ami-020cba7c55df1f615"
  instance_type          = "t2.micro"
  subnet_id              = var.private_subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [var.private_sg_id]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y nginx
              sudo systemctl enable nginx
              sudo systemctl start nginx
              EOF

  tags = {
    Name = "nginx-private"
  }
}

resource "aws_lb" "nginx_alb" {
  name               = "nginx-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [var.public_subnet_id_a, var.public_subnet_id_b]
  security_groups    = [var.private_sg_id]

  tags = {
    Name = "nginx-alb"
  }
}

resource "aws_lb_target_group" "nginx_tg" {
  name     = "nginx-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "nginx_attach" {
  target_group_arn = aws_lb_target_group.nginx_tg.arn
  target_id        = aws_instance.private_nginx.id
  port             = 80
}

resource "aws_lb_listener" "nginx_listener" {
  load_balancer_arn = aws_lb.nginx_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx_tg.arn
  }
}

output "nginx_alb_dns" {
  description = "Public DNS name of the ALB for accessing NGINX"
  value       = aws_lb.nginx_alb.dns_name
}


