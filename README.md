# Terraform AWS Production Infrastructure

Production AWS infrastructure provisioned with Terraform — VPC with public/private subnets, EC2 instances behind Application Load Balancer, RDS PostgreSQL, IAM roles, and CloudWatch monitoring. Based on real production fintech infrastructure supporting high-availability deployments.

---

## Problem Statement

Manually provisioning AWS resources through the Console for production workloads creates undocumented, unreproducible infrastructure. Security groups get overly permissive, IAM policies drift, and there's no audit trail for changes. Need infrastructure-as-code that enforces security boundaries, provides environment parity, and integrates with CI/CD for automated provisioning.

## Solution

Modular Terraform configuration provisioning a complete AWS production environment:
- Multi-AZ VPC with public/private subnet tiers
- EC2 instances in private subnets behind ALB
- RDS PostgreSQL with automated backups and encryption
- IAM roles following least-privilege principle
- CloudWatch alarms and monitoring dashboards

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         AWS Account                             │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                     VPC (10.0.0.0/16)                     │  │
│  │                                                           │  │
│  │  ┌─────────────────────┐  ┌─────────────────────┐        │  │
│  │  │  Public Subnet AZ-a │  │  Public Subnet AZ-b │        │  │
│  │  │  10.0.1.0/24        │  │  10.0.2.0/24        │        │  │
│  │  │  ┌───────────────┐  │  │  ┌───────────────┐  │        │  │
│  │  │  │   NAT Gateway │  │  │  │   NAT Gateway │  │        │  │
│  │  │  └───────────────┘  │  │  └───────────────┘  │        │  │
│  │  └─────────┬───────────┘  └──────────┬──────────┘        │  │
│  │            │    ┌────────────────┐    │                   │  │
│  │            └────┤  ALB (Public)  ├────┘                   │  │
│  │                 │  Port 80/443   │                        │  │
│  │                 └───────┬────────┘                        │  │
│  │                         │                                 │  │
│  │  ┌─────────────────────┼────────────────────────┐        │  │
│  │  │  Private Subnet AZ-a│   Private Subnet AZ-b  │        │  │
│  │  │  10.0.10.0/24       │   10.0.20.0/24         │        │  │
│  │  │  ┌──────────┐       │   ┌──────────┐         │        │  │
│  │  │  │   EC2    │       │   │   EC2    │         │        │  │
│  │  │  │ (App)    │       │   │ (App)    │         │        │  │
│  │  │  └──────────┘       │   └──────────┘         │        │  │
│  │  └─────────────────────┼────────────────────────┘        │  │
│  │                         │                                 │  │
│  │  ┌─────────────────────┼────────────────────────┐        │  │
│  │  │  DB Subnet Group    │                        │        │  │
│  │  │  ┌──────────────────▼───────────────────┐    │        │  │
│  │  │  │         RDS PostgreSQL (Multi-AZ)    │    │        │  │
│  │  │  │         Encrypted · Automated Backup │    │        │  │
│  │  │  └──────────────────────────────────────┘    │        │  │
│  │  └──────────────────────────────────────────────┘        │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │  CloudWatch  │  │   IAM Roles  │  │   S3 (State/Logs)   │  │
│  │  Alarms      │  │  Least-Priv  │  │   Encrypted         │  │
│  └──────────────┘  └──────────────┘  └──────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Repository Structure

```
terraform-aws-production-infra/
├── environments/
│   ├── production/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   ├── outputs.tf
│   │   └── backend.tf           # S3 + DynamoDB state backend
│   └── staging/
│       ├── main.tf
│       ├── variables.tf
│       ├── terraform.tfvars
│       ├── outputs.tf
│       └── backend.tf
├── modules/
│   ├── vpc/
│   │   ├── main.tf              # VPC, subnets, NAT, IGW, route tables
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── alb/
│   │   ├── main.tf              # ALB, target groups, listeners, SSL
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── ec2/
│   │   ├── main.tf              # Launch template, ASG, security groups
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── rds/
│   │   ├── main.tf              # RDS PostgreSQL, subnet group, params
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── iam/
│   │   ├── main.tf              # Roles, policies, instance profiles
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── monitoring/
│       ├── main.tf              # CloudWatch alarms, dashboards
│       ├── variables.tf
│       └── outputs.tf
├── .github/
│   └── workflows/
│       └── terraform.yml        # Plan on PR, Apply on merge
├── .gitignore
├── Makefile
└── README.md
```

---

## Tech Stack

| Component | Technology |
|---|---|
| **IaC** | Terraform >= 1.5 |
| **Cloud** | AWS (us-east-1) |
| **Compute** | EC2 (Auto Scaling Group) |
| **Networking** | VPC, ALB, NAT Gateway |
| **Database** | RDS PostgreSQL (Multi-AZ) |
| **Security** | IAM, Security Groups, KMS encryption |
| **Monitoring** | CloudWatch Alarms + Dashboards |
| **State** | S3 + DynamoDB locking |

---

## Key Features

- **Multi-AZ Deployment** — Resources spread across 2+ availability zones for HA
- **Private Subnets** — Application servers never exposed to the internet directly
- **ALB with SSL** — TLS termination at load balancer, HTTP→HTTPS redirect
- **RDS Encryption** — At-rest encryption with KMS, automated daily backups (7-day retention)
- **Security Groups** — Minimal ingress rules; ALB→EC2→RDS chain only
- **IAM Least Privilege** — Instance profiles with scoped policies, no wildcard permissions
- **CloudWatch Monitoring** — CPU, memory, disk, RDS connection alarms with SNS notifications
- **Remote State** — S3 backend with DynamoDB locking for team collaboration
- **CI/CD Integration** — GitHub Actions pipeline with plan-on-PR, apply-on-merge workflow

---

## Quick Start

```bash
cd environments/production
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

---

## Screenshots (Suggested)

- AWS Console: VPC topology view showing subnets and routing
- ALB target group health check status
- CloudWatch dashboard with key metrics
- Terraform plan output in GitHub Actions PR check

---

## Author

**Sanket Raut** — DevOps Engineer  
[LinkedIn](https://linkedin.com/in/sanket-raut) · [Email](mailto:sanketraut.cloud@gmail.com)
