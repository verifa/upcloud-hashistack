terraform {
  cloud {
    organization = "verifa-io"
    workspaces {
      tags = ["upcloud", "hashistack"]
    }
  }
}

