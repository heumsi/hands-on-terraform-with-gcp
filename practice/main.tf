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

resource "google_service_account" "gce" {
  account_id   = "google-compute-engine"
  display_name = "google-compute-engine"
}

resource "google_compute_instance" "hotwg_asne3_prod_1" {
  name         = "hotwg-asne3-prod-1"
  machine_type = "e2-medium"
  zone         = "asia-northeast3-c"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.hotwg_asne3_prod_1.id
    access_config {
      nat_ip = google_compute_address.hotwg_asne3_prod_1.address
    }
  }

  service_account {
    email  = google_service_account.gce.email
    scopes = ["cloud-platform"]
  }

  tags = ["allow-http", "allow-ssh"]

  metadata = {
    ssh-keys = "default:${file(var.gce_ssh_pub_key_file)}"
  }
}

resource "google_compute_address" "hotwg_asne3_prod_1" {
  name   = "hotwg-asne3-prod-1"
  region = "asia-northeast3"
}

resource "google_compute_firewall" "hotwg_prod_1_allow_ssh" {
  name        = "hotwg-prod-1-allow-ssh"
  network     = google_compute_network.hotwg_prod_1.name
  description = "Allow ssh from anywhere"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-ssh"]
}

resource "google_compute_firewall" "hotwg_prod_1_allow_http" {
  name        = "hotwg-prod-1-allow-http"
  network     = google_compute_network.hotwg_prod_1.name
  description = "Allow http from anywhere"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-http"]
}