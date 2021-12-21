# Demo
Here's how to use the Terraform code to spin up UpCloud managed db and login to it using Vault managed database credentials.

## Before apply
Vault provider has no credentials configured, they will be passed through env vars:
```bash
export VAULT_ADDR=http://<some-public-ip>:8200
export VAULT_TOKEN=<administrative-token>
export UPCLOUD_USERNAME=<upcloud-user-with-api-access>
export UPCLOUD_PASSWORD=<pass>
```
## Terraform apply and client commands

>Persona: Vault operator

First let's spin up the managed database, wait for it to provision and then configure Vault for access control. Vault initially authenticates with the built-in credentials that UpCloud creates automatically.
```bash
terraform apply -auto-approve
```

>Persona: Application admin/user

Now we can consume the Vault role and login:
```bash
read_json=$(vault read $(terraform output -raw vault_mount_path)/creds/admin-role -format=json)
password=$(echo $read_json | jq -r .data.password)
username=$(echo $read_json | jq -r .data.username)
psql postgres://${username}:${password}$(terraform output -raw psql_helper_uri)
```
