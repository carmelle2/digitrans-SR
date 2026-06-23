# Module IAM - Gestion des identités et accès (Principe du moindre privilège)

# Rôle pour EKS Cluster
resource "aws_iam_role" "eks_cluster" {
  name = "${var.project_name}-${var.environment}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-eks-cluster-role"
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Rôle pour EKS Node Group
resource "aws_iam_role" "eks_node" {
  name = "${var.project_name}-${var.environment}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-eks-node-role"
  }
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_ecr_read_only" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Politique pour accès aux secrets (Secrets Manager)
resource "aws_iam_role_policy" "eks_secrets_access" {
  name = "${var.project_name}-${var.environment}-eks-secrets-policy"
  role = aws_iam_role.eks_node.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "kms:Decrypt"
        ]
        Resource = [
          "arn:aws:secretsmanager:${var.aws_region}:*:secret:${var.project_name}/${var.environment}/*",
          var.kms_key_arn
        ]
      }
    ]
  })
}

# Politique pour accès S3 (logs, backups)
resource "aws_iam_role_policy" "eks_s3_access" {
  name = "${var.project_name}-${var.environment}-eks-s3-policy"
  role = aws_iam_role.eks_node.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.project_name}-${var.environment}-*",
          "arn:aws:s3:::${var.project_name}-${var.environment}-*/*"
        ]
      }
    ]
  })
}


# Rôle pour développeurs (accès limité)
resource "aws_iam_role" "developer" {
  name = "${var.project_name}-${var.environment}-developer-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.developer_external_id
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-developer-role"
  }
}

resource "aws_iam_role_policy" "developer" {
  name = "${var.project_name}-${var.environment}-developer-policy"
  role = aws_iam_role.developer.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:ListNodegroups",
          "logs:GetLogEvents",
          "logs:FilterLogEvents",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics"
        ]
        Resource = "*"
      },
      {
        Effect = "Deny"
        Action = [
          "eks:UpdateClusterConfig",
          "eks:DeleteCluster",
          "rds:DeleteDBInstance",
          "rds:ModifyDBInstance"
        ]
        Resource = "*"
      }
    ]
  })
}

# Rôle pour DevOps (accès complet)
resource "aws_iam_role" "devops" {
  name = "${var.project_name}-${var.environment}-devops-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.devops_external_id
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-devops-role"
  }
}

resource "aws_iam_role_policy_attachment" "devops_admin" {
  role       = aws_iam_role.devops.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Utilisateur IAM pour CI/CD existant (gremmy)
data "aws_iam_user" "github_actions" {
  user_name = "gremmy"
}

resource "aws_iam_user_policy" "github_actions" {
  name = "${var.project_name}-${var.environment}-github-actions-policy"
  user = data.aws_iam_user.github_actions.user_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "eks:DescribeCluster",
          "iam:PassRole"
        ]
        Resource = "*"
      }
    ]
  })
}

# Politique de rotation des clés (audit trail)
resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 14
  require_lowercase_characters   = true
  require_uppercase_characters   = true
  require_numbers                = true
  require_symbols                = true
  allow_users_to_change_password = true
  max_password_age               = 90
  password_reuse_prevention      = 24
}

# Data sources
data "aws_caller_identity" "current" {}

# Outputs
output "eks_cluster_role_arn" {
  value = aws_iam_role.eks_cluster.arn
}

output "eks_node_role_arn" {
  value = aws_iam_role.eks_node.arn
}

output "developer_role_arn" {
  value = aws_iam_role.developer.arn
}

output "devops_role_arn" {
  value = aws_iam_role.devops.arn
}

output "github_actions_user_name" {
  value = data.aws_iam_user.github_actions.user_name
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
  type = string
}

variable "developer_external_id" {
  type      = string
  sensitive = true
}

variable "devops_external_id" {
  type      = string
  sensitive = true
}

variable "github_repo" {
  type        = string
  description = "GitHub repository (format: owner/repo)"
}
