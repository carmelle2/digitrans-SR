# Orchestration principale de l'infrastructure DIGITRANS-CM

# Module VPC
module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = var.vpc_cidr
}

# Module Security
module "security" {
  source = "./modules/security"

  project_name         = var.project_name
  environment          = var.environment
  vpc_id               = module.vpc.vpc_id
  allowed_ip_ranges    = var.allowed_ip_ranges
  on_premise_ip_ranges = var.on_premise_ip_ranges

  depends_on = [module.vpc]
}

# Module IAM
module "iam" {
  source = "./modules/iam"

  project_name          = var.project_name
  environment           = var.environment
  aws_region            = var.aws_region
  kms_key_arn           = module.security.kms_key_arn
  developer_external_id = var.developer_external_id
  devops_external_id    = var.devops_external_id
  github_repo           = var.github_repo

  depends_on = [module.security]
}

# Module Storage (S3, ElastiCache Redis)
module "storage" {
  source = "./modules/storage"

  project_name              = var.project_name
  environment               = var.environment
  kms_key_arn               = module.security.kms_key_arn
  private_app_subnet_ids    = module.vpc.private_app_subnet_ids
  redis_security_group_id   = module.security.redis_security_group_id

  depends_on = [module.vpc, module.security]
}



# Module Monitoring
module "monitoring" {
  source = "./modules/monitoring"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region

  depends_on = [module.vpc]
}

# Module Compute (ECS Fargate)
module "compute" {
  source = "./modules/compute"

  project_name                 = var.project_name
  environment                  = var.environment
  aws_region                   = var.aws_region
  vpc_id                       = module.vpc.vpc_id
  public_subnet_ids            = module.vpc.public_subnet_ids
  private_app_subnet_ids       = module.vpc.private_app_subnet_ids
  alb_security_group_id        = module.security.alb_security_group_id
  ecs_tasks_security_group_id  = module.security.ecs_tasks_security_group_id
  eks_cluster_role_arn         = module.iam.eks_cluster_role_arn
  eks_node_role_arn            = module.iam.eks_node_role_arn
  kms_key_arn                  = module.security.kms_key_arn
  alb_logs_bucket              = module.storage.alb_logs_bucket
  acm_certificate_arn          = var.acm_certificate_arn

  depends_on = [module.vpc, module.security, module.iam, module.storage]
}

# Module Budget (Gestion des coûts)
module "budget" {
  source = "./modules/budget"

  project_name    = var.project_name
  environment     = var.environment
  alert_email     = var.alert_email
  monthly_budget_limit = "100"

  depends_on = [module.vpc, module.security, module.iam, module.storage, module.compute]
}

# Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "eks_cluster_name" {
  description = "EKS Cluster Name"
  value       = module.compute.eks_cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS Cluster Endpoint"
  value       = module.compute.eks_cluster_endpoint
}

output "redis_endpoint" {
  description = "Redis endpoint"
  value       = module.storage.redis_endpoint
  sensitive   = true
}

output "github_actions_user_name" {
  description = "GitHub Actions IAM User Name"
  value       = module.iam.github_actions_user_name
}

output "monthly_budget_name" {
  description = "Monthly budget name"
  value       = module.budget.monthly_budget_name
}
