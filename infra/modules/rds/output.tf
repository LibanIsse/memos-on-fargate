output "memos_dsn" {
  value     = "host=${aws_db_instance.postgres_db.address} port=5432 user=postgres password=${data.aws_secretsmanager_secret_version.db_password.secret_string} dbname=database1 sslmode=require"
  sensitive = true
}