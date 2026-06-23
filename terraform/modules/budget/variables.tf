# Variables pour le budget

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "alert_email" {
  type = string
}

variable "monthly_budget_limit" {
  type        = string
  description = "Budget mensuel limite en USD"
  default     = "100"
}

variable "service_budgets" {
  type = map(string)
  description = "Budgets par service AWS (total: 100$)"
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