terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "networking" {
  source = "./modules/networking"
}

module "ssh_key" {
  source   = "./modules/ssh-key"
  key_name = var.key_name
}

module "ec2" {
  source             = "./modules/ec2"
  public_subnet_id   = module.networking.public_subnet_id
  private_subnet_id  = module.networking.private_subnet_id
  bastion_sg_id      = module.networking.bastion_sg_id
  private_sg_id      = module.networking.private_sg_id
  key_name           = module.ssh_key.key_name
}
