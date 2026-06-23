# Infrastructure Hybride AWS pour DIGITRANS-CM
# Région: eu-north-1 (Stockholm) - Free Tier 

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "digitrans-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "eu-north-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "DIGITRANS-CM"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Client      = "AGROCAM-SA"
      CostCenter  = "IT-Infrastructure"
    }
  }
}

