variable "username" {
  type = string
}

variable "password" {
  type = string
}

variable "vault_addr" {
  description = "UUID or name of custom image that includes vault"
  type        = string
  default     = "https://vault.upcloud.verifa.io"
}
