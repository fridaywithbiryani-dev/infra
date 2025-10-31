resource "google_service_account" "gke_service_account" {
  account_id   = "${var.service_account_name}"
  display_name = "GKE Service Account for ${var.cluster_name}"
  project      = var.project_id
}

# Grant roles to the GKE service account for Workload Identity
resource "google_project_iam_member" "gke_sa_self"  {
  project = var.project_id
  for_each = toset(var.roles)
  role    = each.key
  member  = "serviceAccount:${var.project_id}.svc.id.goog[${var.k8s_namespace}/${var.k8s_sa_name}]"
}