# ---------------------------------------------------------------------------
# Pub/Sub — Prescription fulfillment event stream
# Published by the API when a prescription is submitted for fulfillment.
# Dead-letter policy routes undeliverable messages after 5 attempts.
# ---------------------------------------------------------------------------

resource "google_pubsub_topic" "fulfillment_events" {
  name   = "${local.app}-fulfillment"
  labels = local.labels

  kms_key_name               = google_kms_crypto_key.phi_key.id
  message_retention_duration = "86400s"
}

# Grant the Cloud Run SA publish rights scoped to this topic only
resource "google_pubsub_topic_iam_member" "rx_api_sa_publisher" {
  topic  = google_pubsub_topic.fulfillment_events.name
  role   = "roles/pubsub.publisher"
  member = "serviceAccount:${google_service_account.rx_api_sa.email}"
}

resource "google_pubsub_subscription" "fulfillment_sub" {
  name   = "${local.app}-fulfillment-sub"
  topic  = google_pubsub_topic.fulfillment_events.name
  labels = local.labels

  ack_deadline_seconds       = 60
  message_retention_duration = "86400s"
  retain_acked_messages      = false

  expiration_policy {
    ttl = "" # No expiration — durable subscription
  }

  retry_policy {
    minimum_backoff = "10s"
    maximum_backoff = "300s"
  }

  dead_letter_policy {
    dead_letter_topic     = google_pubsub_topic.fulfillment_events.id
    max_delivery_attempts = 5
  }
}
