resource "random_password" "tsdb_postgres" {
  length  = 16
  special = false
}

resource "random_password" "tsdb_replicator" {
  length  = 16
  special = false
}

resource "random_password" "tsdb_rewind_user" {
  length  = 16
  special = false
}

resource "random_password" "rds" {
  length  = 16
  special = false
}