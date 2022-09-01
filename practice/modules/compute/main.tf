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
    subnetwork = var.subnetwork.id
    access_config {
      nat_ip = var.nat_ip.address
    }
  }

  service_account {
    email  = var.service_account.email
    scopes = ["cloud-platform"]
  }

  tags = ["allow-http", "allow-ssh"]

  metadata = {
    ssh-keys = "default:${file(var.ssh_pub_key_file)}"
  }
}