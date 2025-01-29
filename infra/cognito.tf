resource "aws_cognito_user_pool" "user_pool" {
  name = "user_pool_usuarios_processamento_video"

  schema {
    name                = "email"
    attribute_data_type = "String"
    mutable             = true
    required            = true
  }

  schema {
    name                = "phone_number"
    attribute_data_type = "String"
    mutable             = true
    required            = true
  }

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  auto_verified_attributes = ["email", "phone_number"]
}

resource "aws_cognito_user_pool_client" "user_pool_client" {
  name                                 = "user_pool_usuarios_processamento_video_client"
  user_pool_id                         = aws_cognito_user_pool.user_pool.id
  generate_secret                      = false
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["email", "openid", "profile"]
  allowed_oauth_flows_user_pool_client = true
  callback_urls                        = ["https://oauth.pstmn.io/v1/callback"]
  logout_urls                          = ["https://example.com/logout"]
  supported_identity_providers         = ["COGNITO"]
}

resource "aws_cognito_user_pool_domain" "user_pool_domain" {
  domain       = "my-user-pool-domain"
  user_pool_id = aws_cognito_user_pool.user_pool.id
}

resource "aws_cognito_user_group" "user_group" {
  name         = "standard_users"
  user_pool_id = aws_cognito_user_pool.user_pool.id
  description  = "Grupo padrão para usuários cadastrados."
}
