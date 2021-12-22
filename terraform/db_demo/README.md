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

### Problem with destroying
When trying to delete the stack it might fail with error:
```bash
vault_mount.this: Destroying... [id=postgres]
╷
│ Error: error deleting from Vault: Error making API request.
│
│ URL: DELETE http://127.0.0.1:8200/v1/sys/mounts/postgres
│ Code: 400. Errors:
│
│ * failed to revoke "postgres/creds/admin-role/5SXJ0padYZMbhlE5nGwZ3Gsr" (1 / 4): failed to revoke entry: resp: (*logical.Response)(nil) err: failed to find entry for connection with name: "upcloud-postgres"
│
```

You can use Vault cli to forcefully revoke the lease in this case:
```bash
vault write -force /sys/leases/revoke-force/postgres/creds/admin-role
```
There seems to be open issues about this for the Vault provider, for example: https://github.com/hashicorp/terraform-provider-vault/issues/622
