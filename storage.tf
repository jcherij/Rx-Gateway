# ---------------------------------------------------------------------------
# GCS — Prescription PDF storage
# Versioning enabled; retention set to 7 years per HIPAA records policy.
# Uniform bucket-level access enforced (no legacy ACLs).
# Public access prevention enforced at bucket level.
# ---------------------------------------------------------------------------

resource "google_storage_bucket" "rx_pdfs" {
  name                        = "${var.project_id}-${local.app}-pdfs"
  location                    = var.region
  storage_class               = "STANDARD"
  force_destroy               = false
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  labels                      = local.labels

  versioning {
    enabled = true
  }

  retention_policy {
    retention_period = 220752000 # 7 years in seconds
    is_locked        = false
  }

  lifecycle_rule {
    condition { age = 2557 } # ~7 years
    action    { type = "Delete" }
  }
}

# Scoped to objectCreator — write-only access for PDF uploads
resource "google_storage_bucket_iam_member" "rx_pdfs_api_access" {
  bucket = google_storage_bucket.rx_pdfs.name
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:${google_service_account.rx_api_sa.email}"
}
