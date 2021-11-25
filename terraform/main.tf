
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
  size  = 20
  tier  = "maxiops"
  title = "Vault persistent storage"
  zone  = "fi-hel1"
}

resource "upcloud_server" "example" {
  hostname = var.hostname != "" ? var.hostname : "terraform.example.tld"
  zone     = "fi-hel1"
  plan     = "1xCPU-1GB"
  metadata = true

  template {
    # uuid of packer built image
    storage = var.custom_image
    # storage = "01000000-0000-4000-8000-000020060100"
    size = 25
  }

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
    storage = upcloud_storage.vault_storage.id
  }

  # user_data = <<-EOF
  #   #cloud-config
  #   users:
  #     - name: demo
  #       ssh-authorized-keys:
  #         - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCuUG6Aydl+wyu3GZnRYWU9P6v//a1R2KN3PKqrRKfApJ7oa1fnT83c15RMP7ZNGxKYgR/J7F5Z4uo/lr9nXZ/0SeTFHxNK1Vfn6QSN2UlYF4VKCu9akEnnQyMRCT+WrlgKBY1L7kOAv5ZxLgnghUfzDgd1jMHlBb9dXqHezNRp8/tLPfEyn/jZ0ByVGafL9/S0mCToBqQc4tmeligVjJLFogG1LQ4667D+UgtnWTiyuOsmhKDfXGqQXjVCtoONRMAcQYiQZZRWr4CoZ84OZLapIJP56PCwoEVaP2zbx1L6hwR7NOMTdZH1/YzSNzBNSpg5SZ65z9I8nD7J1y0dujjqBzR/iYWlmNLTV1ezssrFL7W9vWCyKlyg0CvwJ34SFP73m3zzy3PsNtAVGBTni8EJDDwiJniSFj7Qehne+5zwiqWPIBOwdyOnKLqMJ6u369NPsqQtTcBBQPZlAFmQjkKyQYINZuEuzTsh/eQxKZNoFriFye58N7j98gQDnrgpLMGcjnxDEDQvmyaiQYXTxAlSuv9pSAVqHlhO7qmPeK2Lmzbpt8mIrtmXqcbs4Szkjwi2siqq1HHyZPRmQqaZXomc4v3K0lqoAGuJ6oYhBjpCZEos8ZZrUv9OMurQqUgRjNYq6LfTLTBs37sdc+RAZwYUEZ/kNm0NRa0wxHoJ2WqGNw== jlarfors@verifa.io
  # EOF
#  user_data = file("./cloud-config.yaml")
  user_data = <<-EOF
    #cloud-config
    users:
    - default
    fs_setup:
    - label: data
      filesystem: 'ext4'
      device: '/dev/sdb'
      partition: 'auto'
      overwrite: 'false'
    manage_etc_hosts: false
    preserve_hostname: true
    disable_root: false
    runcmd:
    - [ touch, /var/lib/cloud/instance/locale-check.skip ]
    mounts:
    - [ sdb, /opt/vault/data, "auto", "defaults,nofail", "0", "0" ]
  EOF
  #fs_setup will just put the fs directly on the disk, consuming all space


  # Configuring connection details
  connection {
    # The server public IP address
    host        = self.network_interface[0].ip_address
    type        = "ssh"
    user        = "root"
    private_key = file("~/.ssh/id_rsa_upcloud")
  }

  #
  # TODO: once we get cloud-config working with upcloud we should redo this.
  # Terraform provisioners suck and should be avoided :)
  # https://www.terraform.io/docs/language/resources/provisioners/syntax.html#provisioners-are-a-last-resort
  #
  provisioner "file" {
    content = jsonencode({
      listener : [{
        tcp : {
          address : "0.0.0.0:8200",
          tls_disable : 1
        }
      }],
      storage : {
        file : {
          path : "/tmp/vault/data"
        }
      },
      # enable the UI
      ui : true
    })
    destination = "/etc/vault.d/config.json"
  }

  # Restart vault systemd service
  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname $(wget -O- -q  http://169.254.169.254/metadata/v1/hostname)",
      "sudo echo 127.0.0.1 $(hostname) >> /etc/hosts",
      "systemctl restart vault",
    ]
  }
}
