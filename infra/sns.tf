resource "aws_sns_topic" "comunicacao_cliente_email_topic" {
  name = "hackathon-comunicacao-cliente"
}

output "sns_topic_arn" {
  value = aws_sns_topic.comunicacao_cliente_email_topic.arn
}

