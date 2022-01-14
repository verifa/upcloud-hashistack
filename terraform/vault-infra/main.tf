module "upcloud_vault" {
  source = "./modules/vault"

  # managed via TFC workspace vars
  custom_image   = var.vault_image
  gcloud-project = var.gcloud-project
  gcloud-region  = var.gcloud-region

  #upcloud creds for go-discover
  username = var.username
  password = var.password

  unseal_provider = "gcp" # no other supported yet
  # pass defaults, but keep them in workspace
  key_ring   = var.key_ring
  crypto_key = var.crypto_key

}
