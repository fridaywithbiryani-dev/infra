
output "storage_bucket_name" {
  description = "The name of the GCS bucket for Terraform state"
  value       = google_storage_bucket.terraform_state_bucket.name
}

output "gke_dev_cluster_name" {
  description = "The name of the GKE development cluster"
  value       = module.gke_dev_cluster.cluster_name
}

output "gke_dev_cluster_endpoint" {
  description = "The endpoint of the GKE development cluster"
  value       = module.gke_dev_cluster.cluster_endpoint
}

output "dev_cluster_ca_certificate" {
  description = "The CA certificate of the GKE development cluster"
  value       = module.gke_dev_cluster.cluster_ca_certificate
}

output "gke_stg_cluster_name" {
  description = "The name of the GKE staging cluster"
  value       = module.gke_stg_cluster.cluster_name
}

output "gke_stg_cluster_endpoint" {
  description = "The endpoint of the GKE staging cluster"
  value       = module.gke_stg_cluster.cluster_endpoint
}

output "stg_cluster_ca_certificate" {
  description = "The CA certificate of the GKE staging cluster"
  value       = module.gke_stg_cluster.cluster_ca_certificate
}

output "dev_gke_service_account_email" {
  description = "The email of the GKE service account for the development cluster"
  value       = module.dev_gke_service_account.service_account_email
}
