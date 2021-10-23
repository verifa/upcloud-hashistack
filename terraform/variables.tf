
variable "username" {
  type = string
}

variable "password" {
  type = string
}

variable "custom_image" {
  description = "UUID or name of custom image that includes vault"
  type        = string
  default     = "0107fa74-499f-468e-aba1-a1f5854c9338"
}
