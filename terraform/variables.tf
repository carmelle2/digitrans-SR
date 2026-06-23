# Variables communes pour tous les environnements

# AWS Configuration
variable "aws_region" {
  description = "AWS Region - eu-north-1 (Stockholm) - Free Tier"
  type        = string
  default     = "eu-north-1"
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
  default     = "123456789012"
}

# Project Configuration
variable "project_name" {
  description = "Project name"
  type        = string
  default     = "digitrans-cm"
}

variable "environment" {
  description = "Environment (dev, test, prod)"
  type        = string
}

# Network Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "allowed_ip_ranges" {
  description = "IP ranges autorisées (Cameroun)"
  type        = list(string)
  default     = ["41.202.0.0/16", "154.72.0.0/16"]
}

variable "on_premise_ip_ranges" {
  description = "IP ranges of on-premise infrastructure"
  type        = list(string)
  default     = ["196.168.1.0/24"]
}

variable "on_premise_public_ip" {
  description = "Public IP of AGROCAM on-premise VPN gateway"
  type        = string
  default     = "196.168.1.1"
}

variable "on_premise_cidr" {
  description = "CIDR block of AGROCAM on-premise network"
  type        = string
  default     = "192.168.0.0/16"
}



# Security Configuration
variable "developer_external_id" {
  description = "External ID for developer role"
  type        = string
  sensitive   = true
}

variable "devops_external_id" {
  description = "External ID for devops role"
  type        = string
  sensitive   = true
}


# ACM Configuration
variable "acm_certificate_arn" {
  description = "ACM certificate ARN for HTTPS"
  type        = string
}


# Monitoring Configuration
variable "alert_email" {
  description = "Email address for alerts"
  type        = string
  default     = "devops@agrocam.cm"
}

variable "canary_artifacts_bucket" {
  description = "S3 bucket for canary artifacts"
  type        = string
  default     = ""
}

# CI/CD Configuration
variable "github_repo" {
  description = "GitHub repository (format: owner/repo)"
  type        = string
  default     = "CAMTECH-SOLUTIONS/digitrans-cm"
}

# Lambda Configuration
variable "rotation_lambda_arn" {
  description = "ARN of Lambda function for secret rotation"
  type        = string
  default     = ""
}

# Budget Configuration
variable "monthly_budget_limit" {
  description = "Monthly budget limit in USD"
  type        = string
  default     = "100"
}

variable "service_budgets" {
  description = "Budgets par service AWS"
  type        = map(string)
  default = {
    "Amazon Elastic Compute Cloud - Compute" = "30"
    "Amazon ElastiCache"                     = "15"
    "Amazon Simple Storage Service"          = "5"
    "Amazon CloudWatch"                      = "5"
    "Amazon Elastic Load Balancing"          = "5"
    "AWS WAF"                                = "3"
    "AWS KMS"                                = "2"
  }
}
