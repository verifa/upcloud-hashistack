
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

  # TODO: this needs to be done now as it does not work to supply the keys
  # when we provision a VM with terraform... for some reason!?
  provisioner "shell" {
    inline = [
      "echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCuUG6Aydl+wyu3GZnRYWU9P6v//a1R2KN3PKqrRKfApJ7oa1fnT83c15RMP7ZNGxKYgR/J7F5Z4uo/lr9nXZ/0SeTFHxNK1Vfn6QSN2UlYF4VKCu9akEnnQyMRCT+WrlgKBY1L7kOAv5ZxLgnghUfzDgd1jMHlBb9dXqHezNRp8/tLPfEyn/jZ0ByVGafL9/S0mCToBqQc4tmeligVjJLFogG1LQ4667D+UgtnWTiyuOsmhKDfXGqQXjVCtoONRMAcQYiQZZRWr4CoZ84OZLapIJP56PCwoEVaP2zbx1L6hwR7NOMTdZH1/YzSNzBNSpg5SZ65z9I8nD7J1y0dujjqBzR/iYWlmNLTV1ezssrFL7W9vWCyKlyg0CvwJ34SFP73m3zzy3PsNtAVGBTni8EJDDwiJniSFj7Qehne+5zwiqWPIBOwdyOnKLqMJ6u369NPsqQtTcBBQPZlAFmQjkKyQYINZuEuzTsh/eQxKZNoFriFye58N7j98gQDnrgpLMGcjnxDEDQvmyaiQYXTxAlSuv9pSAVqHlhO7qmPeK2Lmzbpt8mIrtmXqcbs4Szkjwi2siqq1HHyZPRmQqaZXomc4v3K0lqoAGuJ6oYhBjpCZEos8ZZrUv9OMurQqUgRjNYq6LfTLTBs37sdc+RAZwYUEZ/kNm0NRa0wxHoJ2WqGNw== jlarfors@verifa.io' | tee /root/.ssh/authorized_keys"
    ]
  }
}