# Variables pour l'environnement de développement

environment = "dev"
project_name = "digitrans-cm"
aws_region = "af-south-1"

# Network
vpc_cidr = "10.1.0.0/16"

# Security - IP ranges autorisées (plus permissif en dev)
allowed_ip_ranges = [
  "0.0.0.0/0"  # Accès depuis n'importe où en dev
]

on_premise_ip_ranges = [
  "196.168.1.0/24"
]


# GitHub
github_repo = "CAMTECH-SOLUTIONS/digitrans-cm"

# ACM Certificate
acm_certificate_arn = "arn:aws:acm:af-south-1:ACCOUNT_ID:certificate/CERTIFICATE_ID"

# Monitoring
alert_email = "dev-team@agrocam.cm"

