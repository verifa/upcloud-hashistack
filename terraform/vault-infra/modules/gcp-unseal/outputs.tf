output "private_key" {
  value = google_service_account_key.mykey.private_key
}

output "key_ring" {
  value = var.key_ring
}

output "crypto_key" {
  value = var.crypto_key
}

output "keyring_location" {
  value = var.keyring_location
}
