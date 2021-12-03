
locals {
  vault_url = "https://releases.hashicorp.com/vault"
}

variable "username" {
  type = string
  default = "${env("UPCLOUD_API_USER")}"
}

variable "password" {
  type = string
  default = "${env("UPCLOUD_API_PASSWORD")}"
}

variable "vault_version" {
  type = string
  default = "1.8.4"
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

  provisioner "file" {
    source = "./vault.service"
    destination = "/tmp/vault.service"
  }

  provisioner "shell" {
    script = "./install-vault.sh"
    environment_vars = [
      "VAULT_VERSION=${var.vault_version}"
    ]
  }

  # the image is missing cloud-init, and we must get the latest version from bookworm repos
  provisioner "shell" {
    inline = [
      "cp /etc/apt/sources.list /etc/apt/sources.list.bak",
      "echo \"deb http://deb.debian.org/debian/ bookworm main\" >> /etc/apt/sources.list",
      "echo \"deb-src http://deb.debian.org/debian/ bookworm main\" >> /etc/apt/sources.list",
      "apt update -qq && apt install -y -qq cloud-init=21.4-1",
      "mv /etc/apt/sources.list.bak /etc/apt/sources.list",
    ]
  }
}
