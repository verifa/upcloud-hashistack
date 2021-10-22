
variable "username" {
  type = string
}

variable "password" {
  type = string
}

variable "custom_image" {
  description = "UUID or name of custom image that includes vault"
  type        = string
  default     = "01106712-e0a8-4bde-801b-3c0baf7e8eb6"
}
