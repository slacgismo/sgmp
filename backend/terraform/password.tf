resource "random_password" "tsdb_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "random_password" "mysql_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}