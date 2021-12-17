resource "upcloud_server" "proxy" {
  hostname = "terraform.proxy.example.tld"
  zone     = "fi-hel1"
  plan     = "1xCPU-1GB"
  metadata = true # false by default, must be enabled to enable ssh keys to be injected and cloud-init to run

  template {
    storage = var.custom_image #use the vault image since in the base image cloud-init is broken
    size    = 25
  }

  network_interface {
    type = "public"
  }

  network_interface {
    type    = "private"
    network = upcloud_network.private_network.id
  }

  login {
    user = "root"
    keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC6Itf5BfBIusps0PVJxMvkWGC31K+QQE4MbJ/9T5MBkrNmHX9fr6glF5ezfcQEFYgTVa/Efelar/py5MQmRVbsYSqa5vWWqOB9jPkPWvGK+AJflL6tY/8dv1yXzNQhK3ETgZQNjIwgkVTHsCIXTy6wJioTGWNFf0zjIypv2OqEaxCK90vcyp+y18IHf7iJ4C5gNvs1SQmvF29Ms1LO2iNLypUAw4R5Jt8mNEVgJkbWKxKhTc0WNJJK/fgfTvqr3uBOhcUACTgocGQodkwADjEHw/6Xdk1nZ3KikQKMkY0R5ubS8SAQ2zTXKdVAtAejg4ghS3GzwjHMRoZPh4NSy+JUZK34Wf21BwB9t3mfzFQM6nvfdKPvFZHMeUAOZNg7ZzTMtHe7wkMvs7am0jnUmnT5CfwCBc3PWEggpeokUYrcOyQNnURebL821p8gXjOfgJGDaF2GE+x6ON/wGunbRol4BM0wnGa164POsyhTtFCtGGfHJagw8OdPb80P0fZ10q8=",
    ]
    create_password   = false
    password_delivery = "none"
  }

  user_data = <<EOT
#cloud-config
runcmd:
- ip address add $(wget -O- -q 169.254.169.254/metadata/v1/network/interfaces/2/ip_addresses/1/address)/24 dev eth1
- ip link set dev eth1 up
EOT
}

#resource "upcloud_floating_ip_address" "proxy" {
#  mac_address = upcloud_server.proxy.network_interface[0].mac_address
#}
