variable "project_id" {
  description = "The GCP project ID"
  type        = string
}
variable "service_account_name" {
  description = "The name of the service account"
  type        = string
}
variable "roles" {
  description = "The roles to assign to the service account"
  type        = list(string)
  default = [
    "roles/iam.workloadIdentityUser"
  ]
}
variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
}
variable "k8s_namespace" {
  description = "The Kubernetes namespace for the Workload Identity"
  type        = string
  default     = "default"
}
variable "k8s_sa_name" {
  description = "The Kubernetes service account name for the Workload Identity"
  type        = string
}