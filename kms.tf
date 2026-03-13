# ---------------------------------------------------------------------------
# KMS — Customer-Managed Encryption Key (CMEK)
# Shared key used to encrypt PHI data stores across the stack.
# Rotation is set to 90 days per security policy.
# ---------------------------------------------------------------------------

resource "google_kms_key_ring" "phi_keyring" {
  name     = "${local.app}-keyring"
  location = var.region
}

resource "google_kms_crypto_key" "phi_key" {
  name            = "${local.app}-cmek"
  key_ring        = google_kms_key_ring.phi_keyring.id
  rotation_period = "7776000s" # 90 days

  lifecycle {
    prevent_destroy = true
  }
}
