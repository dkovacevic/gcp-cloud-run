# Define a regional Network Endpoint Group (NEG) for serverless applications.
# This NEG is specifically configured for Cloud Run services.
resource "google_compute_region_network_endpoint_group" "serverless_neg" {
  name = "serverless-neg"
  # The region where the NEG will be created.
  region = var.region
  # Set the endpoint type to SERVERLESS to target services like Cloud Run.
  network_endpoint_type = "SERVERLESS"

  # Cloud Run-specific configuration.
  # This block associates the NEG with the Cloud Run service defined elsewhere.
  cloud_run {
    # Reference the Cloud Run service by its name.
    service = google_cloud_run_v2_service.web_app.name
  }
}

# Define a regional backend service that will use the previously created NEG.
# This backend service is used by the internal load balancer.
resource "google_compute_region_backend_service" "backend_service" {
  name = "cloud-run-backend"
  # The protocol used for communication. Here, it is set to HTTP.
  protocol = "HTTP"
  # Specify that this backend service uses an internal managed load balancing scheme.
  load_balancing_scheme = "INTERNAL_MANAGED"

  region = var.region

  # Backend block to attach the NEG to this backend service.
  backend {
    # Reference the serverless NEG's unique ID.
    group = google_compute_region_network_endpoint_group.serverless_neg.id
  }

  # IAP configuration block.
  iap {
    enabled              = true
    oauth2_client_id     = var.iap_client_id
    oauth2_client_secret = var.iap_client_secret
  }
}
