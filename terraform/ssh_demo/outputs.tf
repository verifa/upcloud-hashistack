
output "role" {
  value = vault_ssh_secret_backend_role.this
}

output "server_public_ip" {
  value = upcloud_server.this.network_interface[0].ip_address
}
