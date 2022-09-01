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

module "compute" {
  source = "./modules/compute"

  subnetwork       = module.network.google_compute_subnetwork["hotwg_asne3_prod_1"]
  nat_ip           = module.network.google_compute_address["hotwg_asne3_prod_1"]
  service_account  = module.iam.service_accounts["gce"]
  ssh_pub_key_file = var.gce_ssh_pub_key_file
}

module "iam" {
  source = "./modules/iam"
}

module "network" {
  source = "./modules/network"
}

moved {
  from = google_compute_firewall.hotwg_prod_1_allow_http
  to   = module.network.google_compute_firewall.hotwg_prod_1_allow_http
}

moved {
  from = google_compute_firewall.hotwg_prod_1_allow_ssh
  to   = module.network.google_compute_firewall.hotwg_prod_1_allow_ssh
}

moved {
  from = google_compute_subnetwork.hotwg_asne3_prod_1
  to   = module.network.google_compute_subnetwork.hotwg_asne3_prod_1
}

moved {
  from = google_service_account.gce
  to   = module.iam.google_service_account.gce
}

moved {
  from = google_compute_network.hotwg_prod_1
  to   = module.network.google_compute_network.hotwg_prod_1
}

moved {
  from = google_compute_instance.hotwg_asne3_prod_1
  to   = module.compute.google_compute_instance.hotwg_asne3_prod_1
}

moved {
  from = google_compute_address.hotwg_asne3_prod_1
  to   = module.network.google_compute_address.hotwg_asne3_prod_1
}