# HashiStack on UpCloud

## High Level Plan

1. Vault for secrets management
2. Consul for service discovery, sub-zone DNS, mTLS, etc
3. Nomad for orchestration

Tools that we will use for all these: Packer and Terraform

## Vault for Secrets Management

### Minimum Viable Product

1. Packer image for Vault
2. Terraform module for creating Vault servers (HA) with Integrated Storage (block storage)
   1. SSO with Google login
   2. Backups
3. Use Cases
   1. SSH access
   2. DB access
   3. ?? K/V store
4. DNS & HTTPS (research needed)

### Packer

Plugin: <https://github.com/UpCloudLtd/packer-plugin-upcloud>
