provider "google" {
  version = "2.8.0"
  project = "${var.project}"
  region  = "${var.region}"
}
resource "google_container_cluster" "primary" {
  name               = "gke-cluster"
  location               = "${var.zone}"
  initial_node_count = 3
  master_auth {
    username = ""
    password = ""
  }
  node_config {
    machine_type = "${var.machine_type}"
    disk_size_gb = "${var.disk_size_gb}"
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
    tags = ["k8s", "otus"]
  }

  addons_config {
    kubernetes_dashboard {
      disabled = false
    }
  }
}

resource "google_compute_firewall" "default" {
  name    = "gke-open-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["30000-32767"]
  }
}

