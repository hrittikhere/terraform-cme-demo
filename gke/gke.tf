# variable "gke_username" {
#   default     = ""
#   description = "gke username"
# }

# variable "gke_password" {
#   default     = ""
#   description = "gke password"
# }


# GKE cluster
resource "google_container_cluster" "primary" {
  name     = "${var.project_id}-gke-harness"
  location = var.region
  
  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name
}

# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name       = "${google_container_cluster.primary.name}"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = var.project_id
    }

    # preemptible  = true
    machine_type = "e2-medium"
    tags         = ["gke-node", "${var.project_id}-harness-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}
