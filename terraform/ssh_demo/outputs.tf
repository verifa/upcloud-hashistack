output "role_name" {
  value = vault_ssh_secret_backend_role.this.name
}
output "default_user" {
  value = vault_ssh_secret_backend_role.this.default_user
}

output "server_public_ip" {
  value = upcloud_server.this.network_interface[0].ip_address
}
