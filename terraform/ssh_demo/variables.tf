variable "image" {
  type    = string
  default = "01377edf-9746-4fc0-9934-dd687f7dd425"
}

variable "vault_addr" {
  description = "UUID or name of custom image that includes vault"
  type        = string
  default     = "https://vault.upcloud.verifa.io"
}
