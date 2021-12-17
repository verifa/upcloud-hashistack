# Demo
Here's how to use the Terraform code to spin up server and login to it using Vault managed SSH keys.
## Before apply
Vault provider has no credentials configured, they will be passed through env vars:
```bash
export VAULT_ADDR=http://<some-public-ip>:8200
export VAULT_TOKEN=<administrative-token>
export TF_VAR_vault_addr=$VAULT_ADDR
export TF_VAR_username=$UPCLOUD_USERNAME
export TF_VAR_password=$UPCLOUD_PASSWORD
```
## Terraform apply and client commands

>Persona: Vault operator

First let's configure the SSH CA and client role in Vault and spin up a server that will fetch the public key from Vault in the user data.
```bash
terraform apply -auto-approve
```

>Persona: Application admin/user

Now we should login and consume the client role:
```bash
vault login -method=userpass bob
# assuming user has run ssh-keygen and has id_rsa and id_rsa.pub in ~/.ssh
vault write -field=signed_key ssh-client-signer/sign/default-role public_key=@$HOME/.ssh/id_rsa.pub > ~/.ssh/id_rsa-cert.pub
# see how long the cert is valid for
ssh-keygen -Lf ~/.ssh/id_rsa-cert.pub
# login
ssh debian@$(terraform output -raw server_public_ip)
```
# TODO
- Create user?
- TLS for Vault or the token is exchanged in plain-text...