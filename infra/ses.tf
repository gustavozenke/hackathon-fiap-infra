resource "aws_ses_email_identity" "email" {
  email = "status-processamento@hacksthonfiap.com"
}

resource "aws_ses_domain_identity" "domain" {
  domain = "hacksthonfiap.com"
}
