# Module Security - Groupes de sécurité et règles de pare-feu

# Security Group pour Application Load Balancer
resource "aws_security_group" "alb" {
  name_description = "${var.project_name}-${var.environment}-alb-sg"
  description      = "Security group for Application Load Balancer"
  vpc_id           = var.vpc_id

  # HTTPS depuis Internet (restreint aux IP Cameroun)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_ip_ranges
    description = "HTTPS from Cameroon IP ranges"
  }

  # HTTP (redirection vers HTTPS)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_ip_ranges
    description = "HTTP from Cameroon IP ranges"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-alb-sg"
  }
}

# Security Group pour ECS Tasks (Microservices)
resource "aws_security_group" "ecs_tasks" {
  name_description = "${var.project_name}-${var.environment}-ecs-tasks-sg"
  description      = "Security group for ECS tasks"
  vpc_id           = var.vpc_id

  # Trafic depuis ALB uniquement
  ingress {
    from_port       = 8081
    to_port         = 8084
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
    description     = "Allow traffic from ALB to microservices"
  }

  # Communication inter-services
  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    self      = true
    description = "Allow inter-service communication"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-ecs-tasks-sg"
  }
}


# Security Group pour ElastiCache Redis
resource "aws_security_group" "redis" {
  name_description = "${var.project_name}-${var.environment}-redis-sg"
  description      = "Security group for ElastiCache Redis"
  vpc_id           = var.vpc_id

  # Redis depuis ECS tasks uniquement
  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks.id]
    description     = "Redis from ECS tasks"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-redis-sg"
  }
}

# Security Group pour VPN (connexion on-premise)
resource "aws_security_group" "vpn" {
  name_description = "${var.project_name}-${var.environment}-vpn-sg"
  description      = "Security group for VPN connection"
  vpc_id           = var.vpc_id

  # IPSec VPN
  ingress {
    from_port   = 500
    to_port     = 500
    protocol    = "udp"
    cidr_blocks = var.on_premise_ip_ranges
    description = "IPSec IKE from on-premise"
  }

  ingress {
    from_port   = 4500
    to_port     = 4500
    protocol    = "udp"
    cidr_blocks = var.on_premise_ip_ranges
    description = "IPSec NAT-T from on-premise"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-vpn-sg"
  }
}

# WAF Web ACL pour protection DDoS et injection SQL
resource "aws_wafv2_web_acl" "main" {
  name  = "${var.project_name}-${var.environment}-waf"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  # Règle 1: Rate limiting (protection DDoS)
  rule {
    name     = "RateLimitRule"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitRule"
      sampled_requests_enabled   = true
    }
  }

  # Règle 2: Protection SQL Injection
  rule {
    name     = "SQLInjectionRule"
    priority = 2

    action {
      block {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesSQLiRuleSet"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "SQLInjectionRule"
      sampled_requests_enabled   = true
    }
  }

  # Règle 3: Protection XSS
  rule {
    name     = "XSSRule"
    priority = 3

    action {
      block {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "XSSRule"
      sampled_requests_enabled   = true
    }
  }

  # Règle 4: Géo-restriction (autoriser uniquement Cameroun et régions spécifiques)
  rule {
    name     = "GeoRestrictionRule"
    priority = 4

    action {
      block {}
    }

    statement {
      not_statement {
        statement {
          geo_match_statement {
            country_codes = ["CM", "FR", "US"] # Cameroun, France, USA
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "GeoRestrictionRule"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project_name}-${var.environment}-waf"
    sampled_requests_enabled   = true
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-waf"
  }
}

# KMS Key pour chiffrement des données
resource "aws_kms_key" "main" {
  description             = "KMS key for ${var.project_name} ${var.environment}"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = {
    Name = "${var.project_name}-${var.environment}-kms"
  }
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.project_name}-${var.environment}"
  target_key_id = aws_kms_key.main.key_id
}

# Outputs
output "alb_security_group_id" {
  value = aws_security_group.alb.id
}

output "ecs_tasks_security_group_id" {
  value = aws_security_group.ecs_tasks.id
}


output "redis_security_group_id" {
  value = aws_security_group.redis.id
}

output "vpn_security_group_id" {
  value = aws_security_group.vpn.id
}

output "waf_web_acl_arn" {
  value = aws_wafv2_web_acl.main.arn
}

output "kms_key_id" {
  value = aws_kms_key.main.id
}

output "kms_key_arn" {
  value = aws_kms_key.main.arn
}

# Variables
variable "vpc_id" {
  type = string
}

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "allowed_ip_ranges" {
  type = list(string)
}

variable "on_premise_ip_ranges" {
  type        = list(string)
  description = "IP ranges of on-premise infrastructure"
  default     = ["196.168.1.0/24"] # IP fictive du datacenter AGROCAM
}
