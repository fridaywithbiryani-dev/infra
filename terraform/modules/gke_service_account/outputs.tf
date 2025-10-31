output "service_account_email" {
  description = "The email of the GKE service account"
  value       = google_service_account.gke_service_account.email
}
output "k8s_namespace" {
  description = "The name of the Kubernetes service account for workload identity"
  value       = var.k8s_namespace
}
output "k8s_sa_name" {
  description = "The namespace of the Kubernetes service account for workload identity"
  value       = var.k8s_sa_name
}