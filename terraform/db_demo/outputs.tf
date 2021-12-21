output "managed_db_service_uri" {
  value     = upcloud_managed_database_postgresql.this.service_uri
  sensitive = true
}
output "public_service_uri" {
  value     = "postgres://${upcloud_managed_database_postgresql.this.service_username}:${upcloud_managed_database_postgresql.this.service_password}@public-${upcloud_managed_database_postgresql.this.service_host}:${upcloud_managed_database_postgresql.this.service_port}/defaultdb?sslmode=require"
  sensitive = true
}
output "psql_helper_uri" {
  value     = "@public-${upcloud_managed_database_postgresql.this.service_host}:${upcloud_managed_database_postgresql.this.service_port}/defaultdb?sslmode=require"
  sensitive = true
}
output "service_password" {
  value     = upcloud_managed_database_postgresql.this.service_password
  sensitive = true
}
output "service_username" {
  value = upcloud_managed_database_postgresql.this.service_username
}
output "service_port" {
  value = upcloud_managed_database_postgresql.this.service_port
}
output "service_host" {
  value = upcloud_managed_database_postgresql.this.service_host
}
output "vault_mount_path" {
  value = vault_mount.this.path
}
