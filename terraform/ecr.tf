# Pas besoin de redéfinir le provider ici, il héritera de la configuration dans main.tf

locals {
  services = ["erp-service", "crm-service", "supply-chain-service", "bi-service", "blockchain-service"]
  project  = "digitrans-cm"
}

resource "aws_ecr_repository" "services" {
  for_each             = toset(local.services)
  name                 = "${local.project}/${each.value}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
