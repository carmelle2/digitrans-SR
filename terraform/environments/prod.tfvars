# Variables pour l'environnement de production

environment = "prod"
project_name = "digitrans-cm"
aws_region = "af-south-1"

# Network
vpc_cidr = "10.0.0.0/16"

# Security - IP ranges autorisées (Cameroun uniquement)
allowed_ip_ranges = [
  "41.202.0.0/16",    # Cameroun Telecom
  "154.72.0.0/16",    # Orange Cameroun
  "196.168.1.0/24"    # AGROCAM On-Premise (fictif)
]

on_premise_ip_ranges = [
  "196.168.1.0/24"    # Datacenter AGROCAM Douala
]

# GitHub
github_repo = "CAMTECH-SOLUTIONS/digitrans-cm"

# ACM Certificate (à créer manuellement)
acm_certificate_arn = "arn:aws:acm:af-south-1:ACCOUNT_ID:certificate/CERTIFICATE_ID"

# Monitoring
alert_email = "devops@agrocam.cm"

