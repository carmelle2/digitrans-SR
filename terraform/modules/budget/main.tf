# Module Budget - Gestion des coûts AWS (100$ pour test)

# Budget mensuel pour le projet
resource "aws_budgets_budget" "monthly" {
  name              = "${var.project_name}-${var.environment}-monthly-budget"
  budget_type       = "COST"
  limit_amount      = var.monthly_budget_limit
  limit_unit        = "USD"
  time_period_start = "2026-01-01_00:00"
  time_unit         = "MONTHLY"

  cost_filters = {
    Tag = {
      "Project" = ["DIGITRANS-CM"]
      "Environment" = [var.environment]
    }
  }

  cost_types {
    include_tax             = true
    include_subscription    = true
    use_blended             = false
  }

  # Alerte à 80% du budget (80$)
  notification {
    notification_type        = "ACTUAL"
    comparison_operator      = "GREATER_THAN"
    threshold                = 80
    threshold_type           = "PERCENTAGE"
    notification_state       = "ALARM"
    subscriber_email_addresses = [var.alert_email]
  }

  # Alerte à 90% du budget (90$)
  notification {
    notification_type        = "ACTUAL"
    comparison_operator      = "GREATER_THAN"
    threshold                = 90
    threshold_type           = "PERCENTAGE"
    notification_state       = "ALARM"
    subscriber_email_addresses = [var.alert_email, "finance@agrocam.cm"]
  }

  # Alerte à 100% du budget (100$)
  notification {
    notification_type        = "FORECASTED"
    comparison_operator      = "GREATER_THAN"
    threshold                = 100
    threshold_type           = "PERCENTAGE"
    notification_state       = "ALARM"
    subscriber_email_addresses = [var.alert_email, "ceo@agrocam.cm"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-monthly-budget"
  }
}

# Budget par service (répartition des 100$)
resource "aws_budgets_budget" "service_budgets" {
  for_each = var.service_budgets

  name              = "${var.project_name}-${var.environment}-${each.key}-budget"
  budget_type       = "COST"
  limit_amount      = each.value
  limit_unit        = "USD"
  time_period_start = "2026-01-01_00:00"
  time_unit         = "MONTHLY"

  cost_filters = {
    Service = [each.key]
    Tag = {
      "Project" = ["DIGITRANS-CM"]
      "Environment" = [var.environment]
    }
  }

  cost_types {
    include_tax             = true
    include_subscription    = true
    use_blended             = false
  }

  notification {
    notification_type        = "ACTUAL"
    comparison_operator      = "GREATER_THAN"
    threshold                = 85
    threshold_type           = "PERCENTAGE"
    notification_state       = "ALARM"
    subscriber_email_addresses = [var.alert_email]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-${each.key}-budget"
    Service = each.key
  }
}

# Outputs
output "monthly_budget_name" {
  value = aws_budgets_budget.monthly.name
}

output "service_budgets" {
  value = {
    for k, v in aws_budgets_budget.service_budgets : k => v.name
  }
}