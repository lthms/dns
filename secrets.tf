variable "gcp_terraform_credentials" {
  type        = string
  description = "Google service account key for Terraform"
  sensitive   = true
}

variable "ovh_client_id" {
  type        = string
  description = "OVHcloud OAuth2 client ID"
  sensitive   = true
}

variable "ovh_client_secret" {
  type        = string
  description = "OVHcloud OAuth2 client secret"
  sensitive   = true
}

# RESP: three, not two — one per variable above, in the "dns" workspace, category
# Terraform variable, all marked sensitive:
#
#   gcp_terraform_credentials  <- the whole service account key JSON, one line
#   ovh_client_id
#   ovh_client_secret
#
# (Or the same three as Environment variables named TF_VAR_<name>; pick one, not
# both.) TF_API_TOKEN is not among them: it authenticates the CI runner *to* HCP,
# so it stays a GitHub secret.
