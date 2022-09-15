# Usage with Terraform Cloud
The file [remote.tf](remote.tf) contains configuration which controls to which Terrafrom Cloud workspace the current root module is linked to, if the config would be using tags then the active workspace would be changed with ```terraform workspace``` command.
## Login and init
```bash
terraform login
terraform init
terraform plan
```
Now you should see the plan in the Terraform Cloud website, see the link from the output of the command.
