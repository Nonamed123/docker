resource "google_container_cluster" "primary1" {
  name               = "marcellus-wallace"
  location           = "us-central1-a"
  initial_node_count = 2
  project = "hardy-symbol-235210"

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }
  addons_config {
    kubernetes_dashboard {
    disabled = false
#    serviceAccount: kubernetes-dashboard
#    serviceAccountName: kubernetes-dashboard
    }
  }
  node_config {
    preemptible  = true
    machine_type = "g1-small"
    disk_size_gb = "20"
    metadata {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    metadata {
      disable-legacy-endpoints = "true"
    }

    labels = {
      foo = "bar"
    }

    tags = ["foo", "bar"]
  }

  timeouts {
    create = "30m"
    update = "40m"
  }
}
resource "google_compute_firewall" "kubernetes-nodeports" {
  name = "kubernetes-nodeports"
  direction = "INGRESS"
  # Название сети, в которой действует правило
  network = "default"
  project = "hardy-symbol-235210"
  # Какой доступ разрешить
  allow {
    protocol = "tcp"
    ports    = ["30000-32767"]
  }

  # Каким адресам разрешаем доступ
  source_ranges = ["0.0.0.0/0"]

  # Правило применимо для инстансов с тегом …
  target_tags = ["reddit-app"]
}
