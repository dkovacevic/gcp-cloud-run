terraform {
  backend "gcs" {
    bucket = "app-tf-state-bucket"
    prefix = "cloud-run-deployment"
  }

  required_providers {
    google = {
      source = "hashicorp/google"
    }

    google-beta = {
      source = "hashicorp/google-beta"
    }
  }
}

provider "google" {
  project = var.project_id
  region = var.region
}

provider "google-beta" {
  project = var.project_id
  region = var.region
}