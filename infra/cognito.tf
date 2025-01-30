resource "aws_cognito_user_pool" "user_pool" {
  name = "user-pool"

  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_subject        = "Account Confirmation"
    email_message        = "Your confirmation code is {####}"
  }

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "email"
    required                 = true

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "phone_number"
    required                 = true

    string_attribute_constraints {
      min_length = 1
      max_length = 20
    }
  }

  username_configuration {
    case_sensitive = false
  }

  mfa_configuration = "OFF"
}

resource "aws_cognito_user_pool_client" "user_pool_client" {
  name         = "appClient"
  user_pool_id = aws_cognito_user_pool.user_pool.id

  generate_secret = true

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = ["openid", "email", "profile"]

  callback_urls = ["https://oauth.pstmn.io/v1/callback"]
  logout_urls   = ["https://oauth.pstmn.io/v1/logout"]

  supported_identity_providers = ["COGNITO"]
}

resource "aws_cognito_user_pool_domain" "cognito-domain" {
  domain       = "login-hackathon-fiap"
  user_pool_id = aws_cognito_user_pool.user_pool.id
}