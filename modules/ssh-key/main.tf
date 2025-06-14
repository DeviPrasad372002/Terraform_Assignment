variable "key_name" {}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated" {
  key_name   = var.key_name
  public_key = tls_private_key.ssh.public_key_openssh
}

# Save the private key to a .pem file
resource "local_sensitive_file" "private_key" {
  content           = tls_private_key.ssh.private_key_pem
  filename          = "${path.module}/my-key.pem"
  file_permission   = "0400"
  
}

output "key_name" {
  value = aws_key_pair.generated.key_name
}

output "private_key_pem" {
  value     = tls_private_key.ssh.private_key_pem
  sensitive = true
}
