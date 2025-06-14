variable "public_subnet_id" {}
variable "private_subnet_id" {}
variable "bastion_sg_id" {}
variable "private_sg_id" {}
variable "key_name" {}

resource "aws_instance" "bastion" {
  ami                         = "ami-020cba7c55df1f615"
  instance_type               = "t2.micro"
  subnet_id                   = var.public_subnet_id
  key_name                    = var.key_name
  vpc_security_group_ids      = [var.bastion_sg_id]
  associate_public_ip_address = true

  tags = {
    Name = "bastion-host"
  }
}

resource "aws_instance" "private_nginx" {
  ami                    = "ami-020cba7c55df1f615"
  instance_type          = "t2.micro"
  subnet_id              = var.private_subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [var.private_sg_id]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum install -y nginx
              sudo systemctl enable nginx
              sudo systemctl start nginx
              EOF

  tags = {
    Name = "nginx-private"
  }
}

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "private_instance_private_ip" {
  value = aws_instance.private_nginx.private_ip
}

