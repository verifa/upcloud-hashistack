variable "username" {
  type = string
  default = "${env("UPCLOUD_API_USER")}"
}

variable "password" {
  type = string
  default = "${env("UPCLOUD_API_PASSWORD")}"
}

packer {
    required_plugins {
        upcloud = {
            version = "v1.2.0"
            source = "github.com/UpCloudLtd/upcloud"
        }
    }
}

source "upcloud" "vault" {
  username = "${var.username}"
  password = "${var.password}"
  zone = "fi-hel1"
  storage_name = "Debian GNU/Linux 11"
  template_prefix = "deb-hashi-vault"
}

build {
  sources = ["source.upcloud.vault"]

  provisioner "shell" {
    inline = [
      "echo yo!"
    ]
  }
}