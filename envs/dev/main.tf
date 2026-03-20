# Dev Environment — lighter footprint, no Multi-AZ, smaller instances

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

locals {
  common_tags = {
    Project     = var.project
    Environment = "dev"
    Terraform   = "true"
    ManagedBy   = "terraform"
  }
}

module "vpc" {
  source = "../../modules/vpc"

  project     = var.project
  environment = "dev"
  vpc_cidr    = "10.1.0.0/16"

  public_subnet_cidrs  = ["10.1.1.0/24"]
  private_subnet_cidrs = ["10.1.10.0/24"]
  availability_zones   = ["us-east-1a"]

  enable_nat_gateway = true
  enable_flow_logs   = false # Save costs in dev

  tags = local.common_tags
}

module "iam" {
  source = "../../modules/iam"

  project     = var.project
  environment = "dev"
  tags        = local.common_tags
}

module "alb" {
  source = "../../modules/alb"

  project           = var.project
  environment       = "dev"
  vpc_id            = module.vpc.vpc_id
  vpc_cidr          = module.vpc.vpc_cidr
  public_subnet_ids = module.vpc.public_subnet_ids
  app_port          = 8080
  health_check_path = "/health"

  tags = local.common_tags
}

module "ec2" {
  source = "../../modules/ec2"

  project              = var.project
  environment          = "dev"
  vpc_id               = module.vpc.vpc_id
  private_subnet_ids   = module.vpc.private_subnet_ids
  instance_type        = "t3.small" # Smaller for dev
  instance_profile_arn = module.iam.ec2_instance_profile_arn
  alb_security_group_id = module.alb.alb_security_group_id
  target_group_arn     = module.alb.target_group_arn

  desired_capacity = 1
  min_size         = 1
  max_size         = 2
  cpu_target       = 80

  tags = local.common_tags
}

module "rds" {
  source = "../../modules/rds"

  project               = var.project
  environment           = "dev"
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  app_security_group_id = module.ec2.app_security_group_id
  instance_class        = "db.t3.micro" # Smallest for dev
  allocated_storage     = 10
  max_allocated_storage = 20
  database_name         = var.database_name
  database_username     = var.database_username
  database_password     = var.database_password

  tags = local.common_tags
}
