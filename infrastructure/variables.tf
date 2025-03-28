# Define the GCP region where resources will be deployed.
variable "region" {
  description = "The GCP region to deploy resources."
  type        = string
  default     = "europe-west1"
}

# Define the CIDR range for the internal subnetwork.
variable "subnetwork" {
  description = "The CIDR range for the internal subnetwork."
  type        = string
  default     = "10.2.0.0/24"
}

# Define the GCP project ID where the resources will be provisioned.
variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

# Define the tag for the Docker image used in the Cloud Run service.
variable "tag" {
  description = "Application Docker image tag."
  type        = string
  default     = "platform-test"
}

# CPU limit for the Cloud Run container.
variable "container_cpu_limit" {
  description = "The CPU limit for the Cloud Run container."
  type        = string
  default     = "1"
}

# Memory limit for the Cloud Run container.
variable "container_memory_limit" {
  description = "The memory limit for the Cloud Run container."
  type        = string
  default     = "1024Mi"
}

# Maximum number of Cloud Run service instances.
variable "max_instance_count" {
  description = "The maximum number of instances for auto-scaling the Cloud Run service."
  type        = number
  default     = 3
}

# Minimum number of Cloud Run service instances.
variable "min_instance_count" {
  description = "The minimum number of instances to keep running for the Cloud Run service."
  type        = number
  default     = 2
}

# Maximum throughput capacity for the VPC Access Connector (in Mbps).
variable "vpc_access_connector_max_throughput" {
  description = "Maximum throughput capacity (in Mbps) for the VPC access connector."
  type        = number
  default     = 500
}

# Minimum throughput capacity for the VPC Access Connector (in Mbps).
variable "vpc_access_connector_min_throughput" {
  description = "Minimum throughput capacity (in Mbps) for the VPC access connector."
  type        = number
  default     = 200
}