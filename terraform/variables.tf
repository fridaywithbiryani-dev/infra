variable "dev_project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "stg_project_id" {
  description = "The GCP staging project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

variable "service_account_name" {
  description = "The name of the service account"
  type        = string
  default     = "terraform-admin-sa"
}
