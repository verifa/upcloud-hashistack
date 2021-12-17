output "vault_ips" {
  value = tomap({
    for k, vault in upcloud_server.vault : k => vault.network_interface[0].ip_address
  })
}
