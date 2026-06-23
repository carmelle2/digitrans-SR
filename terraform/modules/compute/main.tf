# Module Compute - Amazon EKS (Kubernetes)

# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = "${var.project_name}-${var.environment}-cluster"
  role_arn = var.eks_cluster_role_arn

  vpc_config {
    subnet_ids         = concat(var.public_subnet_ids, var.private_app_subnet_ids)
    security_group_ids = [var.ecs_tasks_security_group_id]
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  tags = {
    Name = "${var.project_name}-${var.environment}-eks-cluster"
  }
}

# EKS Node Group (Fargate ou Instances gérées)
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-${var.environment}-node-group"
  node_role_arn   = var.eks_node_role_arn
  subnet_ids      = var.private_app_subnet_ids

  scaling_config {
    desired_size = 2
    max_size     = 10
    min_size     = 2
  }

  instance_types = ["t3.medium"]

  update_config {
    max_unavailable = 1
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-eks-nodes"
  }
}

# ECR Repositories
resource "aws_ecr_repository" "services" {
  for_each = toset(["erp-service", "crm-service", "supply-chain-service", "bi-service", "blockchain-service"])

  name                 = "${var.project_name}/${each.key}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = var.kms_key_arn
  }

  tags = {
    Name = "${var.project_name}-${each.key}"
  }
}

# ECR Lifecycle Policy
resource "aws_ecr_lifecycle_policy" "services" {
  for_each   = aws_ecr_repository.services
  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Delete untagged images after 7 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 7
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# Outputs
output "eks_cluster_name" {
  value = aws_eks_cluster.main.name
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "ecr_repository_urls" {
  value = {
    for k, v in aws_ecr_repository.services : k => v.repository_url
  }
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

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_app_subnet_ids" {
  type = list(string)
}

variable "alb_security_group_id" {
  type = string
}

variable "ecs_tasks_security_group_id" {
  type = string
}

variable "eks_cluster_role_arn" {
  type = string
}

variable "eks_node_role_arn" {
  type = string
}

variable "kms_key_arn" {
  type = string
}

variable "alb_logs_bucket" {
  type = string
}

variable "acm_certificate_arn" {
  type = string
}
