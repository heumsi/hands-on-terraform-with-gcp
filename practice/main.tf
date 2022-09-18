terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.33.0"
    }
  }

  backend "gcs" {
    bucket = "hotwg-asne3-tfstate-prod-1"
  }
}

provider "google" {
  project = var.project
}

module "compute" {
  source = "./modules/compute"

  subnetwork = module.network.google_compute_subnetwork["hotwg_asne3_prod_1"]
  # nat_ip          = module.network.google_compute_address["hotwg_asne3_prod_1"]
  service_account = module.iam.service_accounts["gce"]
}

module "iam" {
  source = "./modules/iam"
}

module "network" {
  source = "./modules/network"
}

module "storage" {
  source = "./modules/storage"
}
