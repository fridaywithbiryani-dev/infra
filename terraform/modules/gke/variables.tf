variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

variable "network" {
  description = "The VPC network for the GKE cluster"
  type        = string
}

variable "subnetwork" {
  description = "The subnetwork for the GKE cluster"
  type        = string
}

variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
}
variable "environment" {
  description = "The environment label for the GKE nodes"
  type        = string
}
variable "node_tags" {
  description = "The network tags for the GKE nodes"
  type        = list(string)
  default     = []
}
variable "min_node_count" {
  description = "The minimum number of nodes in the node pool for autoscaling"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "The maximum number of nodes in the node pool for autoscaling"
  type        = number
  default     = 3
}

variable "node_count" {
  description = "The initial number of nodes in the node pool"
  type        = number
  default     = 1
}

variable "machine_type" {
  description = "The machine type for the GKE nodes"
  type        = string
  default     = "e2-medium"
}
