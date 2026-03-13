variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "Primary GCP region"
  type        = string
  default     = "us-central1"
}

variable "pharmacy_partner_api_key" {
  description = "API key for the downstream pharmacy fulfillment partner — inject via CI secret, never hardcode"
  type        = string
  sensitive   = true
}
