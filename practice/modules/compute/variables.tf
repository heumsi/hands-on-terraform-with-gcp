variable "ssh_pub_key_file" {
  description = "gce public key used by ssh file path"
}

variable "service_account" {
  description = "terraform google_service_account resource"
}

variable "subnetwork" {
  description = "terraform google_compute_subnetwortk resource"
}

variable "nat_ip" {
  description = "terraform google_compute_address resource"
}