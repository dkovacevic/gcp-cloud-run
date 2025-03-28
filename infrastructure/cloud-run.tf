# Define a Cloud Run service using the Cloud Run v2 API.
resource "google_cloud_run_v2_service" "web_app" {
  # Name of the Cloud Run service.
  name     = "hello-web-app"
  # The region where the service is deployed; provided as a variable.
  location = var.region

  # Configure ingress to accept traffic only from an internal load balancer.
  ingress             = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
  # Disable deletion protection for this service to allow easier deletion if needed.
  deletion_protection = false

  # The template block describes the runtime configuration of the service.
  template {
    # Specify the service account used by the Cloud Run service for identity and access management.
    service_account = google_service_account.app_sa.email

    # Container block defines the container settings for the service.
    containers {
      # Image to deploy: pulled from Google Container Registry (GCR).
      # It uses the project ID and tag variables to dynamically reference the correct image.
      image = "gcr.io/${var.project_id}/hello:${var.tag}"

      # Define the ports exposed by the container.
      ports {
        # The container will listen on port 8080.
        container_port = 8080
      }

      # Set resource limits for the container.
      resources {
        limits = {
          # CPU limit from variable.
          cpu    = var.container_cpu_limit
          # Memory limit from variable.
          memory = var.container_memory_limit
        }
      }
    }

    # Scaling block configures the auto-scaling behavior.
    scaling {
      # Maximum number of service instances.
      max_instance_count = var.max_instance_count
      # Minimum number of service instances.
      min_instance_count = var.min_instance_count
    }

    # VPC Access configuration enables the service to connect to a VPC for controlling egress traffic.
    vpc_access {
      # Use the self_link of a previously created VPC Access Connector.
      connector = google_vpc_access_connector.connector.self_link
      # Specify that all outbound traffic should be routed through the VPC connector.
      egress    = "ALL_TRAFFIC"
    }
  }
}
