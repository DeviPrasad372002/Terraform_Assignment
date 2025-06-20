variable "key_name" {}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated" {
  key_name   = var.key_name
  public_key = tls_private_key.ssh.public_key_openssh

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [key_name]
  }
}

resource "local_file" "private_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "${path.module}/${var.key_name}.pem"
  file_permission = "0400"
}

output "key_name" {
  value = aws_key_pair.generated.key_name
}
output "private_key_path" {
  value = local_file.private_key.filename
}
