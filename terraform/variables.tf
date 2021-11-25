
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

variable "network_cidr" {
  type = string
  default = ""
}

variable "network_gw" {
  type = string
  default = ""
}

variable "hostname" {
  type = string
  default = ""
}
