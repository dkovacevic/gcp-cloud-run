# Create a test VM in the same VPC and subnetwork to verify connectivity
resource "google_compute_instance" "test_vm" {
  name         = "test-vm"
  machine_type = "e2-micro"
  zone       = "${var.region}-c"

  # Boot disk with an OS image
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  # Attach the VM to the internal network using the PRIVATE subnetwork
  network_interface {
    network    = google_compute_network.internal_net.id
    subnetwork = google_compute_subnetwork.private_subnet.self_link
  }
  tags = ["ssh-access"]
}

# Create a firewall rule that allows incoming SSH (TCP port 22) traffic.
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.internal_net.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # Restrict access as needed; here we allow from any source (for testing only).
  source_ranges = ["0.0.0.0/0"]

  # Use a target tag so only instances with this tag will allow SSH.
  target_tags = ["ssh-access"]
}