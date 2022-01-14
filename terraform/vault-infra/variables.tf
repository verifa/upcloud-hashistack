variable "vault_image" {
  type = string
}

variable "gcloud-project" {
  type        = string
  description = "Google project name"
}

variable "gcloud-region" {
  type    = string
  default = "europe-north1"
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

variable "username" {
  type = string
}

variable "password" {
  type = string
}