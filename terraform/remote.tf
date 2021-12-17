terraform {
  cloud {
    organization = "verifa-io"
    workspaces {
      name = "upcloud-hashistack-cli-testing"
    }
  }
}

