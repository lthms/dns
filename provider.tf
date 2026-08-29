terraform {
  cloud {
    organization = "lthms"
    workspaces {
      name = "dns"
    }
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.45.0"
    }

    ovh = {
      source  = "ovh/ovh"
      version = "2.19.0"
    }
  }
}

provider "google" {
  credentials = var.gcp_terraform_credentials
  project     = jsondecode(var.gcp_terraform_credentials).project_id
}

provider "ovh" {
  endpoint      = "ovh-eu"
  client_id     = var.ovh_client_id
  client_secret = var.ovh_client_secret
}
