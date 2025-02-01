resource "aws_ses_email_identity" "email_identity" {
  email = "gustavozenke01@gmail.com"
}

resource "aws_ses_configuration_set" "ses_config" {
  name = "default-config-set"
}

resource "aws_ses_domain_identity" "ses_domain" {
  domain = "example.com"
}

resource "aws_ses_domain_dkim" "ses_dkim" {
  domain = aws_ses_domain_identity.ses_domain.domain
}

resource "aws_ses_domain_mail_from" "ses_mail_from" {
  domain           = aws_ses_domain_identity.ses_domain.domain
  mail_from_domain = "teste.example.com"
}

output "ses_identity_arn" {
  value = aws_ses_email_identity.email_identity.arn
}

output "ses_domain_dkim_tokens" {
  value = aws_ses_domain_dkim.ses_dkim.dkim_tokens
}
