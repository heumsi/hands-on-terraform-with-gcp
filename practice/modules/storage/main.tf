resource "google_storage_bucket" "hotwg_asne3_tfstate_prod_1" {
  name          = "hotwg-asne3-tfstate-prod-1"
  force_destroy = false
  location      = "asia-northeast3"
  storage_class = "STANDARD"
  versioning {
    enabled = true
  }
}