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

resource "google_compute_subnetwork" "hotwg_asne3_prod_1" {
  name          = "hotwg-asne3-prod-1"
  ip_cidr_range = "10.1.0.0/16"
  region        = "asia-northeast3"
  network       = google_compute_network.hotwg_prod_1.id
}
