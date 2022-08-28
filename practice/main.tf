terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.33.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_file)
  project     = var.project
}

resource "google_compute_network" "hotwg_prod_1" {
  name                    = "hotwg-prod-1"
  auto_create_subnetworks = false
}
