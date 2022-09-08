data "aws_secretsmanager_secret" "rds" {
  name = "main/rds/password"
}

data "aws_secretsmanager_secret_version" "rds_password" {
  secret_id = data.aws_secretsmanager_secret.rds.id
}

locals {
  rds_password = jsondecode(data.aws_secretsmanager_secret_version.rds_password.secret_string)["password"]
}
