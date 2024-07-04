resource "google_service_account" "cloud_run" {
  account_id = "cloud-run"
}

# サービスアカウントに roles/storage.admin の権限を付与
resource "google_project_iam_member" "storage_admin" {
  project = "${var.project_id}"
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.cloud_run.email}"
}

resource "google_cloud_run_v2_service" "default" {
  name     = "${var.service_name}"
  location = "${var.location}"
  ingress  = "INGRESS_TRAFFIC_ALL"
 
  template {
    service_account = google_service_account.cloud_run.email

    scaling {
      max_instance_count = 1
    }

    containers {
      image = "${var.image_id}"
      ports {
        container_port = 80
      }
    }
  }
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_v2_service.default.location
  project     = google_cloud_run_v2_service.default.project
  service     = google_cloud_run_v2_service.default.name

  policy_data = data.google_iam_policy.noauth.policy_data
}
