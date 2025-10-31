terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.5.0"

  # backend "gcs" {
  #   bucket  = "development-476802-terraform-state-bucket"
  #   prefix  = "terraform/state"
  # }

}

provider "google" {
  project = var.dev_project_id
  region  = var.region
}

data "google_client_config" "default" {}

provider "kubernetes" {
  alias                  = "dev_cluster"
  host                   = "https://${module.gke_dev_cluster.cluster_endpoint}"
  cluster_ca_certificate = base64decode(module.gke_dev_cluster.cluster_ca_certificate)
  token                  = data.google_client_config.default.access_token
}

provider "kubernetes" {
  alias                  = "stg_cluster"
  host                   = "https://${module.gke_stg_cluster.cluster_endpoint}"
  cluster_ca_certificate = base64decode(module.gke_stg_cluster.cluster_ca_certificate)
  token                  = data.google_client_config.default.access_token
}