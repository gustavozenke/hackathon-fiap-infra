resource "aws_sqs_queue" "queue_inicio_processamento" {
  name                      = "sqs-inicio-processamento"
  sqs_managed_sse_enabled   = true
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq_queue_inicio_processamento.arn
    maxReceiveCount     = 4
  })


  tags = {
    Environment = "production"
  }
}

resource "aws_sqs_queue" "dlq_queue_inicio_processamento" {
  name = "dlq-inicio-processamento"
}

resource "aws_sqs_queue_redrive_allow_policy" "terraform_queue_redrive_allow_policy" {
  queue_url = aws_sqs_queue.dlq_queue_inicio_processamento.id

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.queue_inicio_processamento.arn]
  })
}