

resource "google_storage_bucket" "terraform_state_bucket" {
  name     = "${var.dev_project_id}-terraform-state-bucket"
  location = var.region

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 365
    }
  }
}

resource "google_project_service" "container_api" {
  service = "container.googleapis.com"
  project = var.dev_project_id
}

resource "google_project_service" "iam_api" {
  service = "iam.googleapis.com"
  project = var.dev_project_id
}

resource "google_project_service" "enable_gke_api_on_dev" {
  project            = var.dev_project_id
  service            = "container.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "enable_gke_api_on_stg" {
  project            = var.stg_project_id
  service            = "container.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "compute_api" {
  service = "compute.googleapis.com"
  project = var.dev_project_id
}

module "gke_dev_cluster" {
  source         = "./modules/gke"
  project_id     = var.dev_project_id
  region         = "us-central1-a"
  cluster_name   = "dev-gke-cluster"
  network        = "default"
  subnetwork     = "default"
  node_count     = 1
  machine_type   = "e2-medium"
  environment    = "dev"
  node_tags      = ["gke-node", "dev"]
  min_node_count = 1
  max_node_count = 5
}

module "gke_stg_cluster" {
  source         = "./modules/gke"
  project_id     = var.stg_project_id
  region         = "us-central1-a"
  cluster_name   = "stg-gke-cluster"
  network        = "default"
  subnetwork     = "default"
  node_count     = 1
  machine_type   = "e2-medium"
  environment    = "dev"
  node_tags      = ["gke-node", "stg"]
  min_node_count = 1
  max_node_count = 5
}

resource "kubernetes_namespace" "dev_microservices" {
  provider = kubernetes.dev_cluster
  metadata {
    name = "microservices"
  }
  depends_on = [module.gke_dev_cluster]
}

resource "kubernetes_namespace" "stg_microservices" {
  provider = kubernetes.stg_cluster
  metadata {
    name = "microservices"
  }
  depends_on = [module.gke_stg_cluster]
}

module "dev_gke_service_account" {
  source               = "./modules/gke_service_account"
  project_id           = var.dev_project_id
  service_account_name = "dev-gke-workload-identity-sa"
  roles                = ["roles/iam.workloadIdentityUser", "roles/iam.serviceAccountTokenCreator"]
  cluster_name         = module.gke_dev_cluster.cluster_name
  k8s_namespace        = "microservices"
  k8s_sa_name          = "dev-gke-workload-identity-k8s-sa"
}

# Roles to be assigned to the service account
locals {
  cluster_viewer_roles = [
    "roles/container.clusterViewer", # View GKE clusters
    "roles/iam.serviceAccountTokenCreator"
  ]
}

# Grant the dev GCP service account permission to view GKE clusters in the staging project
resource "google_project_iam_member" "dev_sa_on_stg_project" {
  project    = var.stg_project_id
  for_each   = toset(local.cluster_viewer_roles)
  role       = each.key
  member     = "serviceAccount:${module.dev_gke_service_account.service_account_email}"
  depends_on = [module.dev_gke_service_account]
}

resource "kubernetes_service_account" "dev_workload_identity_sa" {
  provider = kubernetes.dev_cluster
  metadata {
    name      = module.dev_gke_service_account.k8s_sa_name
    namespace = "microservices"
    annotations = {
      "iam.gke.io/gcp-service-account" = module.dev_gke_service_account.service_account_email
    }
  }
  depends_on = [module.gke_dev_cluster]
}

# Allow Dev GKE SA to view Stg GKE Cluster
# Roles to be assigned to the service account


# Create RBAC permissions inside staging cluster
resource "kubernetes_cluster_role" "dev_sa_stg_cluster_viewer" {
  provider = kubernetes.stg_cluster
  metadata {
    name = "dev-sa-cluster-viewer"
  }

  rule {
    api_groups = [""]
    resources  = ["namespaces", "pods"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "dev_sa_stg_cluster_viewer_binding" {
  provider = kubernetes.stg_cluster
  metadata {
    name = "dev-sa-cluster-viewer-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.dev_sa_stg_cluster_viewer.metadata[0].name
  }

  subject {
    kind      = "User"
    name      = module.dev_gke_service_account.service_account_email
    api_group = "rbac.authorization.k8s.io"
  }
}

