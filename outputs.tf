output "cloud_run_url" {
  description = "RxGateway API endpoint"
  value       = google_cloud_run_v2_service.rx_api.uri
}

output "sql_instance_connection" {
  description = "Cloud SQL connection name for use with Cloud SQL Auth Proxy"
  value       = google_sql_database_instance.rx_db.connection_name
}

output "pdf_bucket_name" {
  description = "GCS bucket name for prescription PDFs"
  value       = google_storage_bucket.rx_pdfs.name
}

output "kms_key_id" {
  description = "CMEK crypto key ID"
  value       = google_kms_crypto_key.phi_key.id
}
