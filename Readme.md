# Infrastructure as Code

## Requirements:

- Host containerised web app provided using infrastructure as code.
- There must be three environments; dev, stage and prod.
- The workload must run in private environment with explicit ingress and egress control.
- Readable and maintainable solution that is easy to understand.
- Load Balancing solution
- CI/CD

## Overview

This repository contains Terraform configurations that deploy the Hello Web Application on Google Cloud Platform (GCP). The IaC provisions resources such as a Cloud Run service, a serverless Network Endpoint Group (NEG), an internal load balancer backend service, a custom VPC network with subnet, a VPC Access Connector, and necessary service accounts with IAM bindings.

## Table of Contents

- [Overview](#overview)
- [Project Structure](#project-structure)
- [Environment Configuration](#environment-configuration)
- [Resources Provisioned](#resources-provisioned)
- [How to Run](#how-to-run)
- [CI/CD Pipeline](#cicd-pipeline)
- [Prerequisites](#prerequisites)

## Overview

This Terraform-based IaC solution deploys a Cloud Run web application using an internal load balancer with explicit VPC egress control. The configuration is designed to support three environments—**dev**, **stage**, and **prod**—using separate variable files and backend configuration files. Instead of using Terraform workspaces, environment-specific settings are provided through:
- **Variable files:** `dev.tfvars`, `stage.tfvars`, and `prod.tfvars` (which include GCP project IDs and other environment-specific values).
- **Backend configuration files:** Located in the `env` directory (e.g., `env/dev.backend.hcl`, `env/stage.backend.hcl`, and `env/prod.backend.hcl`) that define the storage bucket and other settings for the Terraform state file.

## Project Structure

```
├── infrastructure/             # Contains Terraform configuration files
│   ├── cloud-run.tf            # Cloud Run service
│   ├── dns.tf                  # DNS zone & DNS record set
│   ├── vpc.tf                  # VPC, subnetwork, and related network resources
│   ├── backend-services.tf     # NEG, backend service, etc.
|   ├── load-balancer.tf        # Internal IP, URL map, Proxy, Forwarding rules
│   └── variables.tf            # Variables definitions
├── env/                        # Backend configuration for Terraform state
│   ├── dev.backend.hcl         # Backend config for development environment
│   ├── stage.backend.hcl       # Backend config for staging environment
│   └── prod.backend.hcl        # Backend config for production environment
├── dev.tfvars                  # Environment-specific variables for dev
├── stage.tfvars                # Environment-specific variables for staging
└── prod.tfvars                 # Environment-specific variables for prod
```

## Environment Configuration

- **Variable Files:**  
  - `dev.tfvars`  
  - `stage.tfvars`  
  - `prod.tfvars`  

  Each of these files contains values such as the GCP project ID, region, and other settings specific to an environment.

- **Backend Files:**  
  The `env` directory holds the backend configuration files that define the storage bucket names and other settings used by Terraform to manage state files per environment.

## Resources Provisioned

- **Google Cloud Run Service:**  
  Deploys the `hello-web-app` service with a container image from GCR. It is configured to use an internal load balancer via the `INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER` setting, and it scales between a minimum and maximum number of instances.

- **Serverless NEG & Backend Service:**  
  A serverless Network Endpoint Group (NEG) is created to route traffic from an internal load balancer to the Cloud Run service. The backend service ties this NEG into the internal load balancer configuration.

- **VPC Network & Subnetwork:**  
  A custom VPC network is created along with a subnetwork used by the Cloud Run VPC Access Connector.

- **VPC Access Connector:**  
  Provides VPC connectivity for Cloud Run, enabling explicit egress control through a defined connector.

- **Service Account & IAM Binding:**  
  A dedicated service account is provisioned for the Cloud Run service, and an IAM binding restricts invocation rights to only the designated principal.

- **Internal IP Reservation:**
  The `google_compute_address` resource reserves an internal IP from the specified subnetwork. This IP is used by the load balancer as its frontend.

- **URL Map:**
  The `google_compute_region_url_map directs` all incoming traffic to a backend service defined elsewhere. It serves as the routing table for the load balancer.

- **Target HTTP Proxy:**
   The `google_compute_region_target_http_proxy` binds the URL map to a proxy. This proxy will terminate the HTTP connection and forward requests to the backend service.

- **Forwarding Rule:**
  The `google_compute_forwarding_rule` listens on port 80 for incoming traffic at the reserved internal IP. It then forwards the traffic to the target HTTP proxy. The subnetwork specified must be a PRIVATE subnet, ensuring the IP falls within the correct IP range and meets load balancer requirements.

## How to Run

Follow these steps to deploy the infrastructure for your chosen environment:

1. **Build a docker image and upload it to GCR:**
   ```bash
   PROJECT_ID=<YOUR_GCP_PROJECT_ID>
   docker buildx build --platform linux/amd64 -t gcr.io/$PROJECT_ID/hello:latest .
   docker push gcr.io/$PROJECT_ID/hello:latest
   ```

2. **Navigate to the Infrastructure Directory:**

   ```bash
   cd infrastructure
   ```

3. **Initialize Terraform:**

   Initialize Terraform with the backend configuration file corresponding to your environment (e.g., `dev`):

   ```bash
   terraform init -backend-config="env/dev.backend.hcl"
   ```

4. **Plan the Deployment:**

   Generate an execution plan using the environment-specific variable file:

   ```bash
   terraform plan -var-file="dev.tfvars" -out=tfplan.out
   ```

5. **Apply the Changes:**

   Apply the plan to deploy your resources:

   ```bash
   terraform apply -input=false -auto-approve tfplan.out
   ```
   
6. **Verify the Web app is reachable via LB:**

   Find the IP address of your LB (look for: 'internal-lb-ip)
   ```bash
   gcloud compute addresses list
    ```
   Create a SSH tunnel to a bastion VM:
   ```bash
   gcloud compute ssh test-vm --zone=europe-west1-c -- -L 8080:<YOUR_LB_IP>:80
   ```
   Once the tunnel is established, open your local browser and navigate to http://localhost:8080. Your browser will send traffic through the tunnel, and the bastion host will relay it to the internal load balancer and your app.


7. **Tear down everything:**
   ```bash
   terraform destroy -var-file=dev.tfvars
   ```
    
Replace `dev` with `stage` or `prod` in the above commands when targeting those environments.

## CI/CD Pipeline

A GitHub Actions workflow is provided to automate the deployment process. The workflow is configured to accept a manual input for the environment. The key steps include:

- **Checkout Repository:** Retrieves your source code.
- **Setup Terraform:** Installs the specified version of Terraform.
- **Authenticate to GCP:** Uses a service account (credentials stored as a GitHub secret) to authenticate.
- **Terraform Init:** Initializes Terraform with the environment-specific backend configuration file.
- **Terraform Plan:** Executes the Terraform plan using the environment-specific variable file and outputs the plan to `tfplan.out`.
- **Upload Artifact:** Saves the plan file as an artifact.
- **Terraform Apply:** Applies the Terraform plan automatically.

The workflow is triggered via manual dispatch with an input for the environment (`dev`, `stage`, or `prod`).

## Prerequisites

- **Terraform:** Install Terraform on your system.
- **Google Cloud Platform Account:** Ensure you have a GCP project with the necessary permissions.
- **Bucket in Cloud Storage:** This is the bucket that will hold the state. 
- **Service Account:** Create a service account with roles required for provisioning the resources. Store its credentials as a GitHub secret (e.g., `GCP_SA_KEY`).
- **GitHub Actions:** Set up your repository to use GitHub Actions for continuous deployment.
