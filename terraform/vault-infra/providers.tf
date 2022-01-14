provider "upcloud" {
  # Provided with env vars
  # UPCLOUD_USERNAME
  # UPCLOUD_PASSWORD
}

provider "google" {
  # credentials in TFC are provided through GOOGLE_CREDENTIALS
  #  credentials = file(var.account_file_path)
  project = var.gcloud-project
  region  = var.gcloud-region
}
