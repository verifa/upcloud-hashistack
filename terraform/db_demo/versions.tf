
terraform {
  required_providers {
    upcloud = {
      # use locally built binary of the provider from feat/managed-databases branch
      source  = "registry.upcloud.com/upcloud/upcloud"
      version = "~> 2.1.3"
    }
    vault = {
      source  = "vault"
      version = "~> 3.0.1"
    }
  }
}
