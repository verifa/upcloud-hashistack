provider "vault" {}

provider "upcloud" {
  # Provided with env vars
  # UPCLOUD_USERNAME
  # UPCLOUD_PASSWORD
}

resource "vault_mount" "this" {
  path        = "ssh-client-signer"
  type        = "ssh"
  description = "SSH secrets engine for clients to sign pub keys."
}

resource "vault_ssh_secret_backend_ca" "foo" {
  backend              = vault_mount.this.path
  generate_signing_key = true
}

resource "vault_ssh_secret_backend_role" "this" {
  name                    = "default-role"
  allow_user_certificates = true
  backend                 = vault_mount.this.path
  key_type                = "ca"
  default_user            = "debian"
  allowed_users           = "*"
  ttl                     = "1h"
  max_ttl                 = "24h"
  allowed_extensions      = "permit-pty,permit-port-forwarding"
  default_extensions      = { "permit-pty" : "" } #allows you to get a terminal, nice type...
  algorithm_signer        = "rsa-sha2-512"        #needed for OpenSSH > 8.2
}

resource "upcloud_server" "this" {
  hostname = "terraform.ssh.example.tld"
  zone     = "fi-hel1"
  plan     = "1xCPU-1GB"
  metadata = true # false by default, must be enabled to enable ssh keys to be injected and cloud-init to run

  template {
    storage = var.image
    size    = 25
  }

  network_interface {
    type = "public"
  }

  user_data = templatefile("user_data.tftpl", { ssh_mount_path = vault_mount.this.path, vault_addr = var.vault_addr })
}
