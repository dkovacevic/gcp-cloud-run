# This resource reserves an internal (private) IP address from a specific subnetwork.
resource "google_compute_address" "internal_lb_address" {
  name         = "internal-lb-ip"
  region       = var.region
  address_type = "INTERNAL"
  # The reserved IP will be allocated from the IP range of the specified subnetwork.
  subnetwork   = google_compute_subnetwork.private_subnet.self_link
}

# This resource creates a URL map that directs incoming traffic to a backend service.
resource "google_compute_region_url_map" "lb_url_map" {
  name            = "internal-lb"
  region          = var.region
  # Default service to which all requests will be forwarded.
  default_service = google_compute_region_backend_service.backend_service.self_link
}

# This resource creates a target HTTP proxy which uses the URL map for routing traffic.
resource "google_compute_region_target_http_proxy" "http_proxy" {
  name    = "internal-lb-http-proxy"
  region  = var.region
  url_map = google_compute_region_url_map.lb_url_map.self_link
}

#############################
# Create a Forwarding Rule
# Routes HTTP traffic (port 80) from the reserved IP to the target HTTP proxy.
#############################
resource "google_compute_forwarding_rule" "http_fr" {
  name                  = "http-lb-fr"
  region                = var.region
  load_balancing_scheme = "INTERNAL_MANAGED"  # Specifies internal load balancing.
  # The reserved internal IP address is used as the frontend of the load balancer.
  ip_address            = google_compute_address.internal_lb_address.address  # Input IP.
  # The forwarding rule is associated with a PRIVATE subnetwork.
  subnetwork            = google_compute_subnetwork.private_subnet.self_link
  port_range            = "80"          # The port on which traffic is accepted (HTTP).
  # The target is the HTTP proxy that routes traffic to the backend service.
  target                = google_compute_region_target_http_proxy.http_proxy.id  # Output target.

  depends_on = [google_compute_subnetwork.proxy_subnet]
}
