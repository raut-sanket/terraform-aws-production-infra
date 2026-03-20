# Production Environment — terraform-aws-production-infra
# Full HA deployment with Multi-AZ RDS, NAT Gateways, and CloudWatch monitoring

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
    Environment = "prod"
    Terraform   = "true"
    ManagedBy   = "terraform"
  }
}

# --- Networking ---
module "vpc" {
  source = "../../modules/vpc"

  project     = var.project
  environment = "prod"
  vpc_cidr    = var.vpc_cidr

  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones

  enable_nat_gateway = true
  enable_flow_logs   = true

  tags = local.common_tags
}

# --- IAM ---
module "iam" {
  source = "../../modules/iam"

  project     = var.project
  environment = "prod"
  tags        = local.common_tags
}

# --- Load Balancer ---
module "alb" {
  source = "../../modules/alb"

  project           = var.project
  environment       = "prod"
  vpc_id            = module.vpc.vpc_id
  vpc_cidr          = module.vpc.vpc_cidr
  public_subnet_ids = module.vpc.public_subnet_ids
  app_port          = var.app_port
  health_check_path = var.health_check_path
  certificate_arn   = var.certificate_arn

  tags = local.common_tags
}

# --- Compute ---
module "ec2" {
  source = "../../modules/ec2"

  project              = var.project
  environment          = "prod"
  vpc_id               = module.vpc.vpc_id
  private_subnet_ids   = module.vpc.private_subnet_ids
  instance_type        = var.instance_type
  instance_profile_arn = module.iam.ec2_instance_profile_arn
  alb_security_group_id = module.alb.alb_security_group_id
  target_group_arn     = module.alb.target_group_arn
  app_port             = var.app_port

  desired_capacity = 2
  min_size         = 2
  max_size         = 6
  cpu_target       = 70

  tags = local.common_tags
}

# --- Database ---
module "rds" {
  source = "../../modules/rds"

  project               = var.project
  environment           = "prod"
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  app_security_group_id = module.ec2.app_security_group_id
  instance_class        = var.rds_instance_class
  allocated_storage     = 20
  max_allocated_storage = 100
  database_name         = var.database_name
  database_username     = var.database_username
  database_password     = var.database_password

  tags = local.common_tags
}

# --- Monitoring ---
module "monitoring" {
  source = "../../modules/monitoring"

  project        = var.project
  environment    = "prod"
  alert_email    = var.alert_email
  alb_arn_suffix = module.alb.alb_arn
  asg_name       = module.ec2.asg_name
  rds_identifier = "${var.project}-prod-postgres"

  tags = local.common_tags
}
