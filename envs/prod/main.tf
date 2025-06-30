# This is the main configuration for the PRODUCTION environment

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "multi-env-terraform-state-sng3j05x" # Replace with your bucket name
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = "production"
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}

locals {
  environment = "prod"
  
  ec2_config = {
    instance_type    = "t3.medium"   # Larger instances for production
    min_size         = 2
    max_size         = 6
    desired_capacity = 3
  }
  
  rds_config = {
    instance_class = "db.t3.medium"  # Larger RDS for production
    multi_az       = true            # Always Multi-AZ for production
  }
}

# Same module structure with production configurations
module "vpc" {
  source = "../../modules/vpc"
  
  vpc_cidr     = var.vpc_cidr
  environment  = local.environment
  project_name = var.project_name
}

module "security_groups" {
  source = "../../modules/security_groups"
  
  vpc_id       = module.vpc.vpc_id
  environment  = local.environment
  project_name = var.project_name
}

module "ec2" {
  source = "../../modules/ec2"
  
  ami_id            = var.ami_id
  instance_type     = local.ec2_config.instance_type
  key_name          = var.key_name
  subnet_ids        = module.vpc.private_subnet_ids
  security_group_id = module.security_groups.ec2_security_group_id
  environment       = local.environment
  project_name      = var.project_name
  min_size          = local.ec2_config.min_size
  max_size          = local.ec2_config.max_size
  desired_capacity  = local.ec2_config.desired_capacity
}

module "alb" {
  source = "../../modules/alb"
  
  name              = "${var.project_name}-${local.environment}-alb"
  subnet_ids        = module.vpc.public_subnet_ids
  security_group_id = module.security_groups.alb_security_group_id
  target_group_arn  = module.ec2.target_group_arn
  environment       = local.environment
  project_name      = var.project_name
}

module "rds" {
  source = "../../modules/rds"
  
  db_name           = var.db_name
  username          = var.db_username
  password          = var.db_password
  subnet_ids        = module.vpc.private_subnet_ids
  security_group_id = module.security_groups.rds_security_group_id
  environment       = local.environment
  project_name      = var.project_name
  instance_class    = local.rds_config.instance_class
  multi_az          = local.rds_config.multi_az
}
