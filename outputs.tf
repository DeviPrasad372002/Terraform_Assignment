
output "private_instance_private_ip" {
  value = module.ec2.private_instance_private_ip
}

output "bastion_public_ip" {
  value = module.ec2.bastion_public_ip
}


output "nginx_alb_dns" {
  description = "Public DNS name of the Application Load Balancer"
  value       = module.ec2.nginx_alb_dns
}

