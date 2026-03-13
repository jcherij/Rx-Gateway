# ---------------------------------------------------------------------------
# Service Account
# Dedicated runtime identity for the Cloud Run service.
# Follows least-privilege — only the permissions the API actually needs.
# ---------------------------------------------------------------------------

resource "google_service_account" "rx_api_sa" {
  account_id   = "${local.app}-sa"
  display_name = "RxGateway API Runtime SA"
  description  = "Least-privilege SA for the RxGateway Cloud Run service"
}

# Allow the SA to encrypt/decrypt with the shared CMEK key
resource "google_kms_crypto_key_iam_member" "rx_api_sa_kms" {
  crypto_key_id = google_kms_crypto_key.phi_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_service_account.rx_api_sa.email}"
}
