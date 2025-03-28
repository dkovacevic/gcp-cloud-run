# Create a private DNS zone for internal.example.com
resource "google_dns_managed_zone" "internal" {
  name        = "internal-example-com"
  dns_name    = "internal.example.com."
  description = "Private DNS zone for internal services"
  
  # This makes it a private zone, only accessible within the VPC
  visibility = "private"
  
  private_visibility_config {
    networks {
      network_url = google_compute_network.internal_net.id
    }
  }
}

# Create an A record for the internal load balancer
resource "google_dns_record_set" "internal_lb" {
  name         = "internal.example.com."
  managed_zone = google_dns_managed_zone.internal.name
  type         = "A"
  ttl          = 300
  
  # Point to the internal load balancer IP
  rrdatas = [google_compute_address.internal_lb_address.address]
} 