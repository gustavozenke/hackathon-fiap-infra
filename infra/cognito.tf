resource "aws_cognito_user_pool" "user_pool" {
  name = "user-pool"

  username_attributes = ["email"]
  auto_verified_attributes = ["email"]
  password_policy {
    minimum_length = 6
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_subject = "Account Confirmation"
    email_message = "Your confirmation code is {####}"
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
}

resource "aws_cognito_user_pool_client" "user_pool_client" {
  name         = "appClient"
  user_pool_id = aws_cognito_user_pool.user_pool.id

  generate_secret = false

  allowed_oauth_flows = ["code"]
  allowed_oauth_scopes = ["openid", "email", "profile"]

  callback_urls = ["https://oauth.pstmn.io/v1/callback"]
  logout_urls   = ["https://oauth.pstmn.io/v1/logout"]

  supported_identity_providers = ["COGNITO"]
}

resource "aws_cognito_user_pool_domain" "cognito-domain" {
  domain       = "login-hackathon-fiap"
  user_pool_id = "${aws_cognito_user_pool.user_pool.id}"
}