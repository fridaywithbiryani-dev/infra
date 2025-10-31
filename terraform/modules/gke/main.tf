resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region
  project = var.project_id

  remove_default_node_pool = true
  initial_node_count       = 1

  network = var.network
  subnetwork = var.subnetwork
  # Enable Workload Identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  ip_allocation_policy {}
}

# Create a node pool

resource "google_container_node_pool" "primary_nodes" {
  name       = "${var.cluster_name}-node-pool"
  location   = var.region
  project = var.project_id
  cluster    = google_container_cluster.primary.name
  node_count = var.node_count
  

  node_config {
    machine_type = var.machine_type

    disk_size_gb = 30
    disk_type    = "pd-standard"

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
    labels = {
      env = "${var.environment}"
    }

    tags = var.node_tags
  }

  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}

# Register the cluster to the fleet (GKE Hub)
# resource "google_gke_hub_membership" "this" {
#   project  = var.fleet_project
#   membership_id = var.cluster_name

#   endpoint {
#     gke_cluster {
#       resource_link = "//container.googleapis.com/projects/${var.project_id}/locations/${var.region}/clusters/${google_container_cluster.primary.name}"
#     }
#   }

#   depends_on = [google_container_cluster.primary]
# }