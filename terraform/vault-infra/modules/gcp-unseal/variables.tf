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
