
terraform {
  required_providers {
    upcloud = {
      source  = "UpCloudLtd/upcloud"
      version = "~> 2.1.1"
    }
    vault = {
      source  = "vault"
      version = "~> 3.0.1"
    }
  }
}
