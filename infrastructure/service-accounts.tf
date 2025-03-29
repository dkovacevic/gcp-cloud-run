resource "google_service_account" "app_sa" {
  account_id   = "cloud-run-app"
  display_name = "Service account for Cloud Run application"
}

# Grant the Cloud Run Invoker role to the IAP service account.
resource "google_cloud_run_service_iam_member" "iap_invoker" {
  project  = var.project_id
  location = var.region
  service  = google_cloud_run_v2_service.web_app.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:service-824161654037@gcp-sa-iap.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "iap_user" {
  project = var.project_id
  role    = "roles/iap.httpsResourceAccessor"
  member  = "user:dejankov@gmail.com"
}