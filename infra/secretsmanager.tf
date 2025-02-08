resource "aws_secretsmanager_secret" "email_secret" {
  name        = "email-credentials"
  description = "Secret for email credentials"
}

resource "aws_secretsmanager_secret_version" "email_secret_version" {
  secret_id     = aws_secretsmanager_secret.email_secret.id
  secret_string = jsonencode({
    EMAIL_USER    = "email-default@gmail.com",
    EMAIL_PASSWORD = "senha-default"
  })
}