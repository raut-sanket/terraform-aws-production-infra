#!/bin/bash
set -euo pipefail

# Bootstrap script for application instances
# Installs Docker, pulls app image, starts service

export DEBIAN_FRONTEND=noninteractive

# System updates
apt-get update -y
apt-get upgrade -y

# Install Docker
curl -fsSL https://get.docker.com | sh
systemctl enable docker
systemctl start docker

# Install CloudWatch agent for monitoring
wget -q https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i -E ./amazon-cloudwatch-agent.deb
rm -f ./amazon-cloudwatch-agent.deb

# Log startup
echo "Instance bootstrap complete — env: ${environment}, port: ${app_port}" | logger -t user-data
