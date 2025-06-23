
output "nginx_alb_dns" {
  description = "Public DNS name of the Application Load Balancer"
  value       = module.ec2.nginx_alb_dns
}

