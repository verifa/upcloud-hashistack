# Terraform root module for UpCloud Vault cluster (GCP KMS auto unseal)
This module is meant to be used with TFC cloud in it's default configuration, with small changes it can be run locally as well.

## Importing GCP KMS resources
GCP KMS key ring and keys cannot be deleted for security reasons, see: [https://cloud.google.com/kms/docs/faq#cannot_delete](https://cloud.google.com/kms/docs/faq#cannot_delete). We can however import the existing resources if they happen to already exists from previous runs:
```bash
terraform import module.upcloud_vault.module.gcp_unseal.google_kms_key_ring.key_ring <project-name>/<location>/<key_ring name>
terraform import module.upcloud_vault.module.gcp_unseal.google_kms_crypto_key.crypto_key <project-name>/<location>/<key_ring name>/<key name>
```
