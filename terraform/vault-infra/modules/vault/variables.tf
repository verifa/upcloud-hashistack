variable "username" {
  type = string
}

variable "password" {
  type = string
}

variable "custom_image" {
  description = "UUID or name of custom image that includes vault"
  type        = string
  default     = "01377edf-9746-4fc0-9934-dd687f7dd425"
}

variable "hostname_prefix" {
  type    = string
  default = ""
}

variable "vault_vm_count" {
  type    = number
  default = 3
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "cluster_size" {
  type    = number
  default = 3
}

variable "ssh_pub_key" {
  type = string
  # TODO: either generate a key, or use ~/.ssh/id_rsa.pub as default
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC6Itf5BfBIusps0PVJxMvkWGC31K+QQE4MbJ/9T5MBkrNmHX9fr6glF5ezfcQEFYgTVa/Efelar/py5MQmRVbsYSqa5vWWqOB9jPkPWvGK+AJflL6tY/8dv1yXzNQhK3ETgZQNjIwgkVTHsCIXTy6wJioTGWNFf0zjIypv2OqEaxCK90vcyp+y18IHf7iJ4C5gNvs1SQmvF29Ms1LO2iNLypUAw4R5Jt8mNEVgJkbWKxKhTc0WNJJK/fgfTvqr3uBOhcUACTgocGQodkwADjEHw/6Xdk1nZ3KikQKMkY0R5ubS8SAQ2zTXKdVAtAejg4ghS3GzwjHMRoZPh4NSy+JUZK34Wf21BwB9t3mfzFQM6nvfdKPvFZHMeUAOZNg7ZzTMtHe7wkMvs7am0jnUmnT5CfwCBc3PWEggpeokUYrcOyQNnURebL821p8gXjOfgJGDaF2GE+x6ON/wGunbRol4BM0wnGa164POsyhTtFCtGGfHJagw8OdPb80P0fZ10q8="
}

variable "unseal_provider" {
  type    = string
  default = "gcp"
}

### GCP UNSEAL ###
variable "gcloud-project" {
  type        = string
  description = "Google project name"
}

variable "gcloud-region" {
  type    = string
  default = "europe-north1"
}

variable "gcloud-zone" {
  type    = string
  default = "europe-north1-b"
}

variable "key_ring" {
  type        = string
  description = "Cloud KMS key ring name to create"
  default     = "test"
}

variable "crypto_key" {
  type        = string
  default     = "vault-test"
  description = "Crypto key name to create under the key ring"
}

variable "keyring_location" {
  type    = string
  default = "global"
}
