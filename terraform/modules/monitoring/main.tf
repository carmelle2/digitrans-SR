# Module Monitoring - CloudWatch, SNS, Dashboards

# SNS Topic pour les alertes
resource "aws_sns_topic" "alerts" {
  name              = "${var.project_name}-${var.environment}-alerts"
  display_name      = "DIGITRANS-CM Alerts"
  kms_master_key_id = var.kms_key_arn

  tags = {
    Name = "${var.project_name}-${var.environment}-alerts"
  }
}

# SNS Topic Subscription (Email)
resource "aws_sns_topic_subscription" "alerts_email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-${var.environment}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/EKS", "cluster_node_count", { stat = "Average" }],
            [".", "pod_cpu_utilization", { stat = "Average" }]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "EKS Cluster Resources"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", { stat = "Average" }],
            [".", "DatabaseConnections", { stat = "Sum" }],
            [".", "FreeStorageSpace", { stat = "Average" }]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "RDS Performance"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ElastiCache", "CPUUtilization", { stat = "Average" }],
            [".", "DatabaseMemoryUsagePercentage", { stat = "Average" }],
            [".", "CurrConnections", { stat = "Sum" }]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "Redis Performance"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", { stat = "Average" }],
            [".", "RequestCount", { stat = "Sum" }],
            [".", "HTTPCode_Target_5XX_Count", { stat = "Sum" }],
            [".", "HTTPCode_Target_4XX_Count", { stat = "Sum" }]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "ALB Metrics"
        }
      }
    ]
  })
}

# CloudWatch Log Metric Filters
resource "aws_cloudwatch_log_metric_filter" "error_count" {
  name           = "${var.project_name}-${var.environment}-error-count"
  log_group_name = "/aws/eks/${var.project_name}-${var.environment}-cluster/cluster"
  pattern        = "[ERROR]"

  metric_transformation {
    name      = "ErrorCount"
    namespace = "${var.project_name}/${var.environment}"
    value     = "1"
  }
}

# CloudWatch Alarm pour erreurs applicatives
resource "aws_cloudwatch_metric_alarm" "high_error_rate" {
  alarm_name          = "${var.project_name}-${var.environment}-high-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ErrorCount"
  namespace           = "${var.project_name}/${var.environment}"
  period              = "300"
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "High error rate detected"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  tags = {
    Name = "${var.project_name}-${var.environment}-high-error-rate"
  }
}

# CloudWatch Synthetics Canary pour monitoring de disponibilité
resource "aws_synthetics_canary" "api_health" {
  name                 = "${var.project_name}-${var.environment}-api-health"
  artifact_s3_location = "s3://${var.canary_artifacts_bucket}/canary/"
  execution_role_arn   = aws_iam_role.canary.arn
  handler              = "apiCanaryBlueprint.handler"
  zip_file             = "canary.zip"
  runtime_version      = "syn-nodejs-puppeteer-6.0"

  schedule {
    expression = "rate(5 minutes)"
  }

  run_config {
    timeout_in_seconds = 60
    memory_in_mb       = 960
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-api-health"
  }
}

# IAM Role pour Canary
resource "aws_iam_role" "canary" {
  name = "${var.project_name}-${var.environment}-canary-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-canary-role"
  }
}

resource "aws_iam_role_policy_attachment" "canary" {
  role       = aws_iam_role.canary.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchSyntheticsFullAccess"
}

# CloudWatch Composite Alarm
resource "aws_cloudwatch_composite_alarm" "system_health" {
  alarm_name          = "${var.project_name}-${var.environment}-system-health"
  alarm_description   = "Composite alarm for overall system health"
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.alerts.arn]

  alarm_rule = "ALARM(${aws_cloudwatch_metric_alarm.high_error_rate.alarm_name})"

  tags = {
    Name = "${var.project_name}-${var.environment}-system-health"
  }
}

# Outputs
output "sns_topic_arn" {
  value = aws_sns_topic.alerts.arn
}

output "dashboard_name" {
  value = aws_cloudwatch_dashboard.main.dashboard_name
}

# Variables
variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "kms_key_arn" {
  type    = string
  default = ""
}

variable "alert_email" {
  type        = string
  description = "Email address for alerts"
  default     = "devops@agrocam.cm"
}

variable "canary_artifacts_bucket" {
  type        = string
  description = "S3 bucket for canary artifacts"
  default     = ""
}
