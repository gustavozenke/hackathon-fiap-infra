resource "aws_sqs_queue" "queue_inicio_processamento" {
  name                      = "sqs-inicio-processamento-v2"
  delay_seconds             = 0
  max_message_size          = 262144  # 256KB
  message_retention_seconds = 345600   # 4 dias
  receive_wait_time_seconds = 10
  visibility_timeout_seconds = 30

  kms_master_key_id                 = aws_kms_key.sqs_kms_key.arn
  kms_data_key_reuse_period_seconds = 300

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq_inicio_processamento.arn
    maxReceiveCount     = 3
  })

  policy = data.aws_iam_policy_document.sqs_policy.json

  tags = {
    Environment = "Production"
    Type        = "Standard"
  }
}

resource "aws_sqs_queue" "dlq_inicio_processamento" {
  name                      = "dlq-inicio-processamento-v2"
  message_retention_seconds = 1209600  # 14 dias
  kms_master_key_id         = aws_kms_key.sqs_kms_key.arn

  tags = {
    Environment = "Production"
    Type        = "DLQ"
  }
}

resource "aws_kms_key" "sqs_kms_key" {
  description             = "KMS key for SQS Standard Queues"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms_policy.json
}

data "aws_iam_policy_document" "kms_policy" {
  statement {
    sid       = "AllowSQS"
    effect    = "Allow"
    actions   = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["sqs.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "sqs_policy" {
  statement {
    sid    = "ForceSSL"
    effect = "Deny"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions   = ["SQS:*"]
    resources = [aws_sqs_queue.queue_inicio_processamento.arn]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  statement {
    sid    = "AllowAppAccess"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/EC2-App-Role"]  # Ajuste para seu IAM Role
    }
    actions   = [
      "sqs:SendMessage",
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes"
    ]
    resources = [aws_sqs_queue.queue_inicio_processamento.arn]
  }
}

resource "aws_sqs_queue_public_access_block" "queue_inicio_processamento_public_access_policy" {
  queue_url = aws_sqs_queue.queue_inicio_processamento.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_sqs_queue_public_access_block" "dlq_inicio_processamento_public_access_policy" {
  queue_url = aws_sqs_queue.dlq_inicio_processamento.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_caller_identity" "current" {}

# Outputs
output "queue_inicio_processamento_url" {
  value = aws_sqs_queue.queue_inicio_processamento.url
}

output "queue_inicio_processamento_arn" {
  value = aws_sqs_queue.queue_inicio_processamento.arn
}

output "dlq_inicio_processamento_arn" {
  value = aws_sqs_queue.dlq_inicio_processamento.arn
}