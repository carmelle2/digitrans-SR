# Infrastructure as Code - DIGITRANS-CM

Infrastructure AWS pour le projet DIGITRANS-CM déployée avec Terraform.

## Architecture

### Infrastructure Hybride AWS

```
┌─────────────────────────────────────────────────────────────────┐
│                    AGROCAM On-Premise (Douala)                   │
│                  ┌──────────────────────────────┐                │
│                  │  Datacenter Local            │                │
│                  │  - Données sensibles RH      │                │
│                  │  - Données financières       │                │
│                  └──────────┬───────────────────┘                │
└─────────────────────────────┼─────────────────────────────────────┘
                              │
                              │ VPN Site-to-Site
                              │
┌─────────────────────────────▼─────────────────────────────────────┐
│                      AWS Cloud (af-south-1)                        │
│                                                                    │
│  ┌──────────────────────────────────────────────────────────┐    │
│  │                    VPC (10.0.0.0/16)                     │    │
│  │                                                           │    │
│  │  ┌─────────────────┐         ┌─────────────────┐        │    │
│  │  │  Public Subnet  │         │  Public Subnet  │        │    │
│  │  │   (AZ-1)        │         │   (AZ-2)        │        │    │
│  │  │                 │         │                 │        │    │
│  │  │  ┌───────────┐  │         │  ┌───────────┐  │        │    │
│  │  │  │    ALB    │◄─┼─────────┼─►│    ALB    │  │        │    │
│  │  │  └─────┬─────┘  │         │  └─────┬─────┘  │        │    │
│  │  └────────┼────────┘         └────────┼────────┘        │    │
│  │           │                           │                  │    │
│  │           │  WAF + Shield             │                  │    │
│  │           ▼                           ▼                  │    │
│  │  ┌─────────────────┐         ┌─────────────────┐        │    │
│  │  │ Private Subnet  │         │ Private Subnet  │        │    │
│  │  │   (App - AZ-1)  │         │   (App - AZ-2)  │        │    │
│  │  │                 │         │                 │        │    │
│  │  │ ┌─────────────┐ │         │ ┌─────────────┐ │        │    │
│  │  │ │ ECS Fargate │ │         │ │ ECS Fargate │ │        │    │
│  │  │ │             │ │         │ │             │ │        │    │
│  │  │ │ - ERP       │ │         │ │ - ERP       │ │        │    │
│  │  │ │ - CRM       │ │         │ │ - CRM       │ │        │    │
│  │  │ │ - Supply    │ │         │ │ - Supply    │ │        │    │
│  │  │ │ - BI        │ │         │ │ - BI        │ │        │    │
│  │  │ └──────┬──────┘ │         │ └──────┬──────┘ │        │    │
│  │  └────────┼────────┘         └────────┼────────┘        │    │
│  │           │                           │                  │    │
│  │           │         ┌─────────────────┘                  │    │
│  │           │         │                                    │    │
│  │           ▼         ▼                                    │    │
│  │  ┌─────────────────────────────────────┐                │    │
│  │  │    ElastiCache Redis (Multi-AZ)     │                │    │
│  │  │    - Cache produits (TTL 5 min)     │                │    │
│  │  └─────────────────────────────────────┘                │    │
│  │           │                                              │    │
│  │           ▼                                              │    │
│  │  ┌─────────────────┐         ┌─────────────────┐        │    │
│  │  │ Private Subnet  │         │ Private Subnet  │        │    │
│  │  │   (DB - AZ-1)   │         │   (DB - AZ-2)   │        │    │
│  │  │                 │         │                 │        │    │
│  │  │ ┌─────────────┐ │         │ ┌─────────────┐ │        │    │
│  │  │ │ RDS Primary │ │         │ │ RDS Standby │ │        │    │
│  │  │ │             │◄┼─────────┼─┤             │ │        │    │
│  │  │ │ - erp_db    │ │         │ │ - erp_db    │ │        │    │
│  │  │ │ - crm_db    │ │         │ │ - crm_db    │ │        │    │
│  │  │ │ - supply_db │ │         │ │ - supply_db │ │        │    │
│  │  │ └─────────────┘ │         │ └─────────────┘ │        │    │
│  │  └─────────────────┘         └─────────────────┘        │    │
│  │                                                           │    │
│  └───────────────────────────────────────────────────────────┘    │
│                                                                    │
│  ┌──────────────────────────────────────────────────────────┐    │
│  │                    Services Managés                       │    │
│  │                                                           │    │
│  │  - S3 (Logs, Backups)                                    │    │
│  │  - CloudWatch (Monitoring, Logs)                         │    │
│  │  - Secrets Manager (Credentials)                         │    │
│  │  - KMS (Encryption)                                      │    │
│  │  - ECR (Docker Images)                                   │    │
│  │  - IAM (Access Management)                               │    │
│  └──────────────────────────────────────────────────────────┘    │
└────────────────────────────────────────────────────────────────────┘
```

## Composants

### Réseau (VPC)
- **VPC** : 10.0.0.0/16 (prod), 10.1.0.0/16 (dev)
- **Sous-réseaux publics** : 2 AZ pour ALB
- **Sous-réseaux privés (app)** : 2 AZ pour ECS Fargate
- **Sous-réseaux privés (db)** : 2 AZ pour RDS
- **NAT Gateway** : 2 (un par AZ)
- **VPC Flow Logs** : Audit réseau

### Sécurité
- **WAF** : Protection DDoS, SQL Injection, XSS
- **Security Groups** : Principe du moindre privilège
- **KMS** : Chiffrement des données au repos
- **Secrets Manager** : Gestion des credentials
- **IAM Roles** : Accès basé sur les rôles
- **VPN Site-to-Site** : Connexion sécurisée on-premise

### Compute (ECS Fargate)
- **ECS Cluster** : Orchestration des conteneurs
- **4 Services** : ERP, CRM, Supply Chain, BI
- **Auto Scaling** : 2-10 instances par service
- **ALB** : Load balancing avec HTTPS
- **ECR** : Registre Docker privé

### Cache
- **ElastiCache Redis 7** : Multi-AZ
- **Réplication** : 2 nœuds
- **TTL** : 5 minutes pour produits
- **Encryption** : KMS + TLS

### Monitoring
- **CloudWatch** : Métriques, logs, alarmes
- **SNS** : Notifications d'alertes
- **Dashboard** : Vue d'ensemble système
- **Synthetics Canary** : Tests de disponibilité

## Prérequis

- Terraform >= 1.5.0
- AWS CLI configuré
- Compte AWS avec permissions AdministratorAccess
- GitHub repository configuré

## Installation

### 1. Cloner le repository

```bash
git clone https://github.com/CAMTECH-SOLUTIONS/digitrans-cm.git
cd digitrans-cm/terraform
```

### 2. Initialiser Terraform

```bash
terraform init
```

### 3. Créer le backend S3 (première fois uniquement)

```bash
aws s3api create-bucket \
  --bucket digitrans-terraform-state \
  --region af-south-1 \
  --create-bucket-configuration LocationConstraint=af-south-1

aws s3api put-bucket-versioning \
  --bucket digitrans-terraform-state \
  --versioning-configuration Status=Enabled

aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region af-south-1
```

### 4. Créer les secrets

```bash
# Créer les external IDs pour IAM
aws secretsmanager create-secret \
  --name digitrans-cm/prod/developer-external-id \
  --secret-string "$(openssl rand -hex 32)" \
  --region af-south-1

aws secretsmanager create-secret \
  --name digitrans-cm/prod/devops-external-id \
  --secret-string "$(openssl rand -hex 32)" \
  --region af-south-1
```

### 5. Créer un certificat SSL (ACM)

```bash
# Demander un certificat pour votre domaine
aws acm request-certificate \
  --domain-name digitrans.agrocam.cm \
  --subject-alternative-names "*.digitrans.agrocam.cm" \
  --validation-method DNS \
  --region af-south-1

# Noter l'ARN du certificat et le mettre dans prod.tfvars
```

### 6. Configurer les variables

Créer un fichier `terraform.tfvars` :

```hcl
db_username = "postgres"
db_password = "VotreMotDePasseSecurise123!"
developer_external_id = "votre-external-id-developer"
devops_external_id = "votre-external-id-devops"
```

### 7. Planifier le déploiement

```bash
# Environnement de développement
terraform plan -var-file="environments/dev.tfvars"

# Environnement de production
terraform plan -var-file="environments/prod.tfvars"
```

### 8. Déployer l'infrastructure

```bash
# Développement
terraform apply -var-file="environments/dev.tfvars"

# Production
terraform apply -var-file="environments/prod.tfvars"
```

## CI/CD avec GitHub Actions

### Configuration

1. **Configurer OIDC pour GitHub Actions**

```bash
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
```

2. **Ajouter les secrets GitHub**

Dans votre repository GitHub, aller dans Settings > Secrets and variables > Actions :

- `AWS_ACCOUNT_ID` : Votre ID de compte AWS
- `AWS_ROLE_ARN` : ARN du rôle GitHub Actions (output Terraform)

### Workflow

Le pipeline CI/CD s'exécute automatiquement sur :
- Push sur `main` → Déploiement en production
- Push sur `develop` → Déploiement en développement
- Pull Request → Tests uniquement

Étapes :
1. Build et tests Maven
2. Scan de sécurité (Trivy)
3. Build et push images Docker vers ECR
4. Déploiement sur ECS Fargate
5. Tests d'intégration
6. Notification

## Gestion des coûts

### Estimation mensuelle (Production)

| Service | Configuration | Coût estimé |
|---------|--------------|-------------|
| ECS Fargate | 8 tasks (0.5 vCPU, 1GB) | ~$50 |

| ElastiCache Redis | cache.t3.medium Multi-AZ | ~$100 |
| ALB | 1 ALB + data transfer | ~$30 |
| NAT Gateway | 2 NAT + data transfer | ~$90 |
| S3 | Logs + backups (100GB) | ~$5 |
| CloudWatch | Logs + métriques | ~$20 |
| **Total** | | **~$695/mois** |

### Optimisations

- **Auto Scaling** : Réduction automatique en heures creuses
- **S3 Lifecycle** : Archivage automatique vers Glacier
- **CloudWatch Logs** : Rétention limitée à 30 jours

## Sécurité

### Conformité

- ✅ **Loi camerounaise n°2010/012** : Données sensibles on-premise
- ✅ **GDPR** : Chiffrement, audit, droit à l'oubli
- ✅ **PCI-DSS** : Séparation réseau, chiffrement

### Bonnes pratiques

- Chiffrement au repos (KMS) et en transit (TLS)
- Principe du moindre privilège (IAM)
- Rotation automatique des secrets (90 jours)
- Audit complet (CloudTrail, VPC Flow Logs)
- Backups automatiques (30 jours)
- Multi-AZ pour haute disponibilité

## Maintenance


### Mise à jour

```bash
# Mettre à jour l'infrastructure
terraform plan -var-file="environments/prod.tfvars"
terraform apply -var-file="environments/prod.tfvars"
```

## Troubleshooting

### Erreur : "Error creating DB Instance"

Vérifier que les sous-réseaux DB sont dans des AZ différentes.

### Erreur : "Error creating ECS Service"

Vérifier que les images Docker sont bien poussées dans ECR.

### Erreur : "Certificate not validated"

Valider le certificat ACM via DNS avant de déployer.

## Support

- **Email** : devops@agrocam.cm
- **Documentation** : https://docs.digitrans.agrocam.cm
- **Issues** : https://github.com/CAMTECH-SOLUTIONS/digitrans-cm/issues

## Auteurs

- **CAMTECH SOLUTIONS S.A.** - Équipe DevOps
- **Projet** : DIGITRANS-CM pour AGROCAM S.A.
- **Année** : 2026
