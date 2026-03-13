# ---------------------------------------------------------------------------
# Secret Manager — Pharmacy partner API key
# Used by the API at runtime to authenticate outbound fulfillment requests.
# Replication is single-region to match the deployment footprint.
# ---------------------------------------------------------------------------

resource "google_secret_manager_secret" "pharmacy_api_key" {
  secret_id = "${local.app}-pharmacy-api-key"
  labels    = local.labels

  replication {
    user_managed {
      replicas {
        location = var.region
        customer_managed_encryption {
          kms_key_name = google_kms_crypto_key.phi_key.id
        }
      }
    }
  }
}

resource "google_secret_manager_secret_version" "pharmacy_api_key_v1" {
  secret      = google_secret_manager_secret.pharmacy_api_key.id
  secret_data = var.pharmacy_partner_api_key
}

# Grant the Cloud Run SA read access scoped to this secret only
resource "google_secret_manager_secret_iam_member" "rx_api_sa_secret" {
  secret_id = google_secret_manager_secret.pharmacy_api_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.rx_api_sa.email}"
}
