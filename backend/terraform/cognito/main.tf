data "aws_cognito_user_pools" "pool" {
  name = "sgmp-user"
}

resource "aws_cognito_user_pool_client" "client" {
  name         = "backend-api"
  user_pool_id = tolist(data.aws_cognito_user_pools.pool.ids)[0]

  access_token_validity   = 24
  id_token_validity       = 24
  refresh_token_validity  = 30
  enable_token_revocation = true
  explicit_auth_flows = [
    "ALLOW_CUSTOM_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
  prevent_user_existence_errors = "ENABLED"
  generate_secret               = false
  read_attributes               = ["custom:home", "email", "email_verified", "family_name", "given_name", "middle_name", "name", "nickname", "phone_number", "phone_number_verified", "picture", "preferred_username", "profile", "updated_at"]
  write_attributes              = ["family_name", "given_name", "name", "middle_name", "phone_number", "picture", "preferred_username", "profile", "updated_at"]
}

output "user_pool_arn" {
  value = tolist(data.aws_cognito_user_pools.pool.arns)[0]
}

output "user_pool_id" {
  value = tolist(data.aws_cognito_user_pools.pool.ids)[0]
}

output "app_client_id" {
  value = aws_cognito_user_pool_client.client.id
}