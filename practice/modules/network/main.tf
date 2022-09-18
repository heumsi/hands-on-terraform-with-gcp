# google_compute_network
resource "google_compute_network" "hotwg_prod_1" {
  name                    = "hotwg-prod-1"
  auto_create_subnetworks = false
}

# google_compute_subnetwork
resource "google_compute_subnetwork" "hotwg_asne3_prod_1" {
  name          = "hotwg-asne3-prod-1"
  ip_cidr_range = "10.1.0.0/16"
  region        = "asia-northeast3"
  network       = google_compute_network.hotwg_prod_1.id
}

# google_compute_firewall
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

# google_compute_address
# resource "google_compute_address" "hotwg_asne3_prod_1" {
#   name   = "hotwg-asne3-prod-1"
#   region = "asia-northeast3"
# }