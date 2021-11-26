
provider "upcloud" {
  username = var.username
  password = var.password
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
  count    = var.vault_vm_count
  hostname = var.hostname_prefix != "" ? "${var.hostname_prefix}${count.index}.example.ltf" : "terraform${count.index}.example.tld"
  zone     = "fi-hel1"
  plan     = "1xCPU-1GB"
  metadata = true # false by default, must be enabled to enable ssh keys to be injected and cloud-init

  template {
    # uuid of packer built image
    storage = var.custom_image
    # storage = "01000000-0000-4000-8000-000020060100"
    size = 25
  }

# Something wrong with tags or my account, running with this ruins state!
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
    storage = upcloud_storage.vault_storage[count.index].id
  }

  user_data = templatefile("user_data.tftpl", { count = count.index })

}
