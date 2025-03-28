resource "google_service_account" "app_sa" {
  account_id   = "cloud-run-app"
  display_name = "Service account for Cloud Run application"
}

# Allow unauthenticated (public) access to the Cloud Run service by granting the run.invoker role to allUsers.
resource "google_cloud_run_service_iam_member" "noauth" {
  service  = google_cloud_run_v2_service.web_app.name
  location = google_cloud_run_v2_service.web_app.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}