# Create a VPC Access Connector that allows Cloud Run services to connect to the VPC network.
#resource "google_vpc_access_connector" "connector" {
#  name = "vpc-connector"  # Name of the VPC access connector.
#
#  # Define the subnet for the connector. This references the internal subnetwork created below.
#  subnet {
#    name = google_compute_subnetwork.connector_subnet.name
#  }
#
#  region         = var.region  # The region where the connector is deployed.
#  max_throughput = var.vpc_access_connector_max_throughput  # Maximum throughput capacity in Mbps.
#  min_throughput = var.vpc_access_connector_min_throughput  # Minimum throughput capacity in Mbps.
#}

## Create a reserved proxy-only subnetwork for the load balancer. For the Frontend
resource "google_compute_subnetwork" "proxy_subnet" {
  name          = "proxy-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  network       = google_compute_network.internal_net.id

  # The purpose "REGIONAL_MANAGED_PROXY" reserves this subnet for load balancer use,
  # enabling address reservations for internal ALBs.
  purpose = "REGIONAL_MANAGED_PROXY"
  role    = "ACTIVE"  # Must be set to ACTIVE for the subnet to be used.
}

resource "google_compute_subnetwork" "private_subnet" {
  name          = "private-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.internal_net.id

  purpose = "PRIVATE"
}

#resource "google_compute_subnetwork" "connector_subnet" {
#  name          = "connector-subnet"
#  ip_cidr_range = "10.0.2.0/28"
#  region        = var.region
#  network       = google_compute_network.internal_net.id
#
#  purpose = "PRIVATE"
#}

# Define a custom VPC network
resource "google_compute_network" "internal_net" {
  name                    = "run-network"  # Name of the VPC network.
  auto_create_subnetworks = false
  # Disable automatic creation of subnetworks; custom subnets will be created manually.
}


