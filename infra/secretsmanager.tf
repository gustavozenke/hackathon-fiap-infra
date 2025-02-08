resource "aws_secretsmanager_secret" "sms_secret" {
  name        = "ss-credentials"
  description = "Secrets ara armazenar credenciais para envio de comunicacao SMS"
}

resource "aws_secretsmanager_secret_version" "sms_secret_version" {
  secret_id     = aws_secretsmanager_secret.sms_secret.id
  secret_string = jsonencode({
    USER_POOL_ID    = "default",
    TWILIO_ACCOUNT_SID = "default",
    TWILIO_AUTH_TOKEN = "default",
    TWILIO_PHONE_NUMBER = "default"
  })
}