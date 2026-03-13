# ---------------------------------------------------------------------------
# Cloud Run — RxGateway API service
# Handles prescription submission, PDF generation, and fulfillment dispatch.
# Connects to Cloud SQL via IAM authentication — no password credentials.
# External partner credentials injected at runtime from Secret Manager.
# ---------------------------------------------------------------------------

resource "google_cloud_run_v2_service" "rx_api" {
  name     = local.app
  location = var.region
  labels   = local.labels

  ingress = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = google_service_account.rx_api_sa.email

    scaling {
      min_instance_count = 1
      max_instance_count = 10
    }

    containers {
      image = "gcr.io/${var.project_id}/${local.app}:latest"

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
        cpu_idle = false
      }

      env {
        name  = "DB_INSTANCE"
        value = google_sql_database_instance.rx_db.connection_name
      }

      env {
        name  = "DB_NAME"
        value = google_sql_database.rx_schema.name
      }

      env {
        name  = "DB_USER"
        value = google_sql_user.rx_api_user.name
      }

      env {
        name  = "PDF_BUCKET"
        value = google_storage_bucket.rx_pdfs.name
      }

      env {
        name  = "FULFILLMENT_TOPIC"
        value = google_pubsub_topic.fulfillment_events.id
      }

      # Pharmacy partner API key sourced from Secret Manager at container startup
      env {
        name = "PHARMACY_PARTNER_API_KEY"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.pharmacy_api_key.secret_id
            version = "latest"
          }
        }
      }

      liveness_probe {
        http_get {
          path = "/healthz"
          port = 8080
        }
        initial_delay_seconds = 10
        period_seconds        = 30
      }
    }
  }
}
