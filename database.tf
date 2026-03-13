# ---------------------------------------------------------------------------
# Cloud SQL — PostgreSQL (prescriptions database)
# REGIONAL availability for production uptime requirements.
# No public IP; accessible only via Cloud SQL Auth Proxy or private VPC.
# IAM database authentication enforced — no password-based logins.
# ---------------------------------------------------------------------------

resource "google_sql_database_instance" "rx_db" {
  name                = "${local.app}-postgres"
  database_version    = "POSTGRES_15"
  region              = var.region
  encryption_key_name = google_kms_crypto_key.phi_key.id

  settings {
    tier              = "db-g1-small"
    availability_type = "REGIONAL"
    disk_autoresize   = true
    disk_size         = 20
    disk_type         = "PD_SSD"

    ip_configuration {
      ipv4_enabled    = false
      private_network = "projects/${var.project_id}/global/networks/default"
      require_ssl     = true
    }

    backup_configuration {
      enabled                        = true
      start_time                     = "02:00"
      point_in_time_recovery_enabled = true
      transaction_log_retention_days = 7
    }

    # Enable query insights for performance monitoring
    insights_config {
      query_insights_enabled  = true
      query_string_length     = 1024
      record_application_tags = true
    }

    # Audit connection events to Cloud Logging
    database_flags {
      name  = "log_connections"
      value = "on"
    }

    database_flags {
      name  = "log_disconnections"
      value = "on"
    }

    database_flags {
      name  = "cloudsql.iam_authentication"
      value = "on"
    }
  }

  deletion_protection = true
}

resource "google_sql_database" "rx_schema" {
  name     = "prescriptions"
  instance = google_sql_database_instance.rx_db.name
}

# IAM-based database user mapped to the Cloud Run service account
resource "google_sql_user" "rx_api_user" {
  name     = google_service_account.rx_api_sa.email
  instance = google_sql_database_instance.rx_db.name
  type     = "CLOUD_IAM_SERVICE_ACCOUNT"
}
