
provider "upcloud" {
  username = var.username
  password = var.password
}

locals {
  # include '\\.' in the regex
  discovery_regex = var.hostname_prefix != "" ? "^${var.hostname_prefix}[0-9]+\\\\.vault" : "^terraform[0-9]+\\\\.vault"

  # for_each variable to allow rolling ugprades by swapping image parameter value
  vault_servers = {
    0 = {
      "image" : var.custom_image
      "unseal_keys": var.unseal_keys
# When upgrading change image one-by-one (standbys)
#      "image" : var.custom_image
# Unseal just this one:
#      "unseal_keys": var.unseal_keys
# Skip unsealing (perhaps starting from scratch):
#      "unseal_keys": []
    },
    1 = {
      "image" : var.custom_image
      "unseal_keys": []
    },
    2 = {
      "image" : var.custom_image
      "unseal_keys": []
    },
  }
}

# resource "upcloud_floating_ip_address" "my_floating_address" {
#   zone = "fi-hel1"
# }

resource "upcloud_network" "private_network" {
  name = "example_private_net"
  zone = "fi-hel1"

  # router = upcloud_router.example_router.id

  ip_network {
    address            = var.network_cidr != "" ? var.network_cidr : "10.0.0.0/24"
    dhcp               = true
    dhcp_default_route = false
    family             = "IPv4"
    gateway            = var.network_gw != "" ? var.network_gw : "10.0.0.1"
  }
}


resource "upcloud_storage" "vault_storage" {
  count = var.vault_vm_count
  size  = 20
  tier  = "maxiops"
  title = "Vault persistent storage ${count.index}"
  zone  = "fi-hel1"
}

resource "upcloud_server" "vault" {
  for_each = local.vault_servers
  hostname = var.hostname_prefix != "" ? "${var.hostname_prefix}${each.key}.vault.example.tld" : "terraform${each.key}.vault.example.tld"
  zone     = "fi-hel1"
  plan     = "1xCPU-1GB"
  metadata = true # false by default, must be enabled to enable ssh keys to be injected and cloud-init to run

  template {
    # uuid of packer built image
    storage = var.custom_image
    # storage = "01000000-0000-4000-8000-000020060100"
    size = 25
  }

  # Only main account can create tags, don't use
  #  tags = [
  #    "vault-${var.environment}"
  #  ]

  # network_interface {
  #   type    = "private"
  #   network = upcloud_network.private_network.id
  # }

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
    # mounts are dependent on the key of the vault_server!
    storage = upcloud_storage.vault_storage[each.key].id
  }

  user_data = templatefile("user_data.tftpl", { index = each.key,
    regex    = local.discovery_regex,
    username = var.username,
    password = var.password,
  unseal_keys = local.vault_servers[each.key].unseal_keys })

}
