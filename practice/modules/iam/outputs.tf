output "service_accounts" {
  value = {
    "gce" : google_service_account.gce
  }
}
