output "vpc_id" {
  value = module.vpc.vpc_id
}

output "alb_dns_name" {
  description = "ALB DNS name — point your domain here"
  value       = module.alb.alb_dns_name
}

output "rds_endpoint" {
  description = "RDS connection endpoint"
  value       = module.rds.rds_endpoint
  sensitive   = true
}

output "nat_gateway_ips" {
  description = "NAT Gateway public IPs — whitelist these for external services"
  value       = module.vpc.nat_gateway_ips
}
