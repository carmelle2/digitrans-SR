# Module VPN - Connexion Site-to-Site vers datacenter AGROCAM

# Customer Gateway (côté on-premise AGROCAM Douala)
resource "aws_customer_gateway" "agrocam_douala" {
  bgp_asn    = 65000
  ip_address = var.on_premise_public_ip
  type       = "ipsec.1"

  tags = {
    Name = "${var.project_name}-${var.environment}-cgw-douala"
  }
}

# Virtual Private Gateway (côté AWS)
resource "aws_vpn_gateway" "main" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.project_name}-${var.environment}-vgw"
  }
}

# VPN Gateway Attachment
resource "aws_vpn_gateway_attachment" "main" {
  vpc_id         = var.vpc_id
  vpn_gateway_id = aws_vpn_gateway.main.id
}

# VPN Connection
resource "aws_vpn_connection" "agrocam" {
  vpn_gateway_id      = aws_vpn_gateway.main.id
  customer_gateway_id = aws_customer_gateway.agrocam_douala.id
  type                = "ipsec.1"
  static_routes_only  = true

  tunnel1_inside_cidr   = "169.254.10.0/30"
  tunnel1_preshared_key = var.vpn_tunnel1_preshared_key

  tunnel2_inside_cidr   = "169.254.11.0/30"
  tunnel2_preshared_key = var.vpn_tunnel2_preshared_key

  tags = {
    Name = "${var.project_name}-${var.environment}-vpn-agrocam"
  }
}

# Static Routes vers le réseau on-premise
resource "aws_vpn_connection_route" "on_premise_network" {
  destination_cidr_block = var.on_premise_cidr
  vpn_connection_id      = aws_vpn_connection.agrocam.id
}

# Route Table propagation
resource "aws_vpn_gateway_route_propagation" "private_app" {
  count          = length(var.private_route_table_ids)
  vpn_gateway_id = aws_vpn_gateway.main.id
  route_table_id = var.private_route_table_ids[count.index]
}

# Security Group pour accès bases de données on-premise
resource "aws_security_group" "vpn_database_access" {
  name_description = "${var.project_name}-${var.environment}-vpn-db-access-sg"
  description      = "Allow ECS tasks to access on-premise databases via VPN"
  vpc_id           = var.vpc_id

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.on_premise_cidr]
    description = "PostgreSQL to on-premise databases"
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.on_premise_cidr]
    description = "HTTPS to on-premise services"
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-vpn-db-access-sg"
  }
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "vpn_tunnel1_down" {
  alarm_name          = "${var.project_name}-${var.environment}-vpn-tunnel1-down"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "TunnelState"
  namespace           = "AWS/VPN"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "1"
  alarm_description   = "VPN Tunnel 1 is down"
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    VpnId = aws_vpn_connection.agrocam.id
  }
}

# Outputs
output "vpn_connection_id" {
  value = aws_vpn_connection.agrocam.id
}

output "vpn_gateway_id" {
  value = aws_vpn_gateway.main.id
}

output "tunnel1_address" {
  value     = aws_vpn_connection.agrocam.tunnel1_address
  sensitive = true
}

output "tunnel2_address" {
  value     = aws_vpn_connection.agrocam.tunnel2_address
  sensitive = true
}

output "vpn_database_access_sg_id" {
  value = aws_security_group.vpn_database_access.id
}

# Variables
variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "on_premise_public_ip" {
  type        = string
  description = "Public IP of AGROCAM on-premise VPN gateway"
}

variable "on_premise_cidr" {
  type        = string
  description = "CIDR block of AGROCAM on-premise network"
  default     = "192.168.0.0/16"
}

variable "vpn_tunnel1_preshared_key" {
  type        = string
  sensitive   = true
}

variable "vpn_tunnel2_preshared_key" {
  type        = string
  sensitive   = true
}

variable "private_route_table_ids" {
  type = list(string)
}

variable "sns_topic_arn" {
  type = string
}
