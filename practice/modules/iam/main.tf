resource "google_service_account" "gce" {
  account_id   = "google-compute-engine"
  display_name = "google-compute-engine"
}