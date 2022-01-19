# Usage with Terraform Cloud
The file [remote.tf](remote.tf) contains configuration which controls to which Terrafrom Cloud workspace the current root module is linked to, if the config would be using tags then the active workspace would be changed with ```terraform workspace``` command.
## Login and init
```bash
terraform login
terraform init
terraform plan
```
Now you should see the plan in the Terraform Cloud website, see the link from the output of the command.

## Problems passing variables from localhost (TFC CLI mode)
I was having problem passing in env variables for the UpCloud credentials when they are not saved in TFC, at least with 1.1.0 terraform I had to do the following to pass the values properly from localhost:
```bash
terraform plan -var "password=\"$TF_VAR_password\"" -var "username=\"$TF_VAR_username\""
```
This whole "CLI mode" -feature was just released, so it might be fixed in near future.
