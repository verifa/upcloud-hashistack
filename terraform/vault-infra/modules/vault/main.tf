locals {
  # include '\\.' in the regex
  discovery_regex = var.hostname_prefix != "" ? "^${var.hostname_prefix}[0-9]+\\\\.vault" : "^terraform[0-9]+\\\\.vault"

  # for_each variables to allow rolling ugprades by swapping image parameter value
  #vault_servers = [0, 1, 2]
  #vault_image_ids = [var.custom_image, var.custom_image, var.custom_image]
  vault_servers = {
    0 = {
      "image" : var.custom_image
    },
    1 = {
      "image" : var.custom_image
    },
    2 = {
      "image" : var.custom_image
    },
  }
}

module "gcp_unseal" {
  source = "../gcp-unseal"

  # managed by TFC workspace vars
  key_ring   = var.key_ring
  crypto_key = var.crypto_key
  gcloud-project = var.gcloud-project
  gcloud-region = var.gcloud-region
}

resource "upcloud_storage" "vault_storage" {
  count = var.vault_vm_count
  size  = 20
  tier  = "maxiops"
  title = "Vault persistent storage ${count.index}"
  zone  = "fi-hel1"
}

resource "upcloud_server" "vault" {
  # need to convert number to list of strings 3=["0","1","2"]
  for_each = toset(formatlist("%s", (range(var.vault_vm_count))))
  hostname = var.hostname_prefix != "" ? "${var.hostname_prefix}${each.key}.vault.example.tld" : "terraform${each.key}.vault.example.tld"
  zone     = "fi-hel1"
  plan     = "1xCPU-1GB"
  metadata = true # false by default, must be enabled to enable ssh keys to be injected and cloud-init to run

  template {
    # uuid of packer built image
    storage = local.vault_servers[each.key].image
    size    = 25
  }

  # Only main account can create tags, don't use
  #  tags = [
  #    "vault-${var.environment}"
  #  ]

  network_interface {
    type = "public"
  }

  login {
    user = "root"
    keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC6Itf5BfBIusps0PVJxMvkWGC31K+QQE4MbJ/9T5MBkrNmHX9fr6glF5ezfcQEFYgTVa/Efelar/py5MQmRVbsYSqa5vWWqOB9jPkPWvGK+AJflL6tY/8dv1yXzNQhK3ETgZQNjIwgkVTHsCIXTy6wJioTGWNFf0zjIypv2OqEaxCK90vcyp+y18IHf7iJ4C5gNvs1SQmvF29Ms1LO2iNLypUAw4R5Jt8mNEVgJkbWKxKhTc0WNJJK/fgfTvqr3uBOhcUACTgocGQodkwADjEHw/6Xdk1nZ3KikQKMkY0R5ubS8SAQ2zTXKdVAtAejg4ghS3GzwjHMRoZPh4NSy+JUZK34Wf21BwB9t3mfzFQM6nvfdKPvFZHMeUAOZNg7ZzTMtHe7wkMvs7am0jnUmnT5CfwCBc3PWEggpeokUYrcOyQNnURebL821p8gXjOfgJGDaF2GE+x6ON/wGunbRol4BM0wnGa164POsyhTtFCtGGfHJagw8OdPb80P0fZ10q8=",
    ]
    create_password   = false
    password_delivery = "none"
  }

  storage_devices {
    storage = upcloud_storage.vault_storage[each.key].id
  }

  user_data = templatefile("${path.module}/gcp_user_data.tftpl", { index = each.key,
    regex          = local.discovery_regex,
    username       = var.username,
    gcloud-project = var.gcloud-project,
    keyring_location : module.gcp_unseal.keyring_location,
    key_ring    = module.gcp_unseal.key_ring,
    crypto_key  = module.gcp_unseal.crypto_key,
    credentials = module.gcp_unseal.private_key,
  password = var.password, })
}
