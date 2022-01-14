variable "username" {
  type = string
}

variable "password" {
  type = string
}

variable "custom_image" {
  description = "UUID or name of custom image that includes vault"
  type        = string
  default     = "01532eae-f224-48f6-a696-96c609b11489"
}

variable "hostname_prefix" {
  type    = string
  default = ""
}

variable "vault_vm_count" {
  type    = number
  default = 3
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "cluster_size" {
  type    = number
  default = 3
}

variable "unseal_provider" {
  type    = string
  default = "gcp"
}

### GCP UNSEAL ###
variable "gcloud-project" {
  type        = string
  description = "Google project name"
}

variable "gcloud-region" {
  type    = string
  default = "europe-north1"
}

variable "gcloud-zone" {
  type    = string
  default = "europe-north1-b"
}

variable "key_ring" {
  type        = string
  description = "Cloud KMS key ring name to create"
  default     = "test"
}

variable "crypto_key" {
  type        = string
  default     = "vault-test"
  description = "Crypto key name to create under the key ring"
}

variable "keyring_location" {
  type    = string
  default = "global"
}
