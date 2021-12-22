provider "vault" {}

provider "upcloud" {
  # Provided with env vars
  # UPCLOUD_USERNAME
  # UPCLOUD_PASSWORD
  #  username = var.username
  #  password = var.password
}

resource "vault_mount" "this" {
  path        = "postgres"
  type        = "database"
  description = "Managed UpCloud database."
}

resource "upcloud_managed_database_postgresql" "this" {
  name = "vault-managed-postgres"
  plan = "1x1xCPU-2GB-25GB"
  zone = "fi-hel1"
  properties {
    public_access = true
    ip_filter     = ["0.0.0.0/0"]
  }
}

resource "null_resource" "wait_for_dns" {
  depends_on = [upcloud_managed_database_postgresql.this]
  provisioner "local-exec" {
    command = "until nslookup public-${upcloud_managed_database_postgresql.this.service_host}; do sleep 5; done"
  }
}

resource "vault_database_secret_backend_connection" "this" {
  depends_on    = [null_resource.wait_for_dns]
  backend       = vault_mount.this.path
  name          = "upcloud-postgres"
  allowed_roles = ["admin-role"]

  postgresql {
    connection_url = "postgres://${upcloud_managed_database_postgresql.this.service_username}:${upcloud_managed_database_postgresql.this.service_password}@public-${upcloud_managed_database_postgresql.this.service_host}:${upcloud_managed_database_postgresql.this.service_port}/defaultdb?sslmode=require"
  }
}

resource "vault_database_secret_backend_role" "this" {
  backend             = vault_mount.this.path
  name                = "admin-role"
  db_name             = vault_database_secret_backend_connection.this.name
  creation_statements = ["CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";"]
}
