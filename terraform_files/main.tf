terraform {
  required_version = ">= 1.0.0"
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0.0"
    }
  }
}

module "k3s" {
  source = "./modules/k3s"
}

