resource "aws_sqs_queue" "queue_inicio_processamento" {
  name                      = "sqs-inicio-processamento"
  sqs_managed_sse_enabled   = true
  delay_seconds             = 0
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 0
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

resource "aws_sqs_queue_redrive_allow_policy" "queue_inicio_processamento_redrive_allow_policy" {
  queue_url = aws_sqs_queue.dlq_queue_inicio_processamento.id

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.queue_inicio_processamento.arn]
  })
}

resource "aws_sqs_queue_policy" "queue_policy_inicio_processamento" {
  queue_url = aws_sqs_queue.queue_inicio_processamento.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "s3.amazonaws.com"
        },
        Action = "SQS:SendMessage",
        Resource = aws_sqs_queue.queue_inicio_processamento.arn,
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_s3_bucket.bucket_raw_videos.arn
          }
        }
      }
    ]
  })
}

# ---------------------------------------------------------------------------


resource "aws_sqs_queue" "queue_processamento" {
  name                      = "sqs-processamento"
  sqs_managed_sse_enabled   = true
  delay_seconds             = 0
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 0
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq_queue_processamento.arn
    maxReceiveCount     = 4
  })


  tags = {
    Environment = "production"
  }
}

resource "aws_sqs_queue" "dlq_queue_processamento" {
  name = "dlq-processamento"
}

resource "aws_sqs_queue_redrive_allow_policy" "queue_processamento_redrive_allow_policy" {
  queue_url = aws_sqs_queue.dlq_queue_processamento.id

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.queue_processamento.arn]
  })
}

# ---------------------------------------------------------------------------

resource "aws_sqs_queue" "queue_gravar_status_processamento" {
  name                      = "sqs-gravar-status-processamento"
  sqs_managed_sse_enabled   = true
  delay_seconds             = 0
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 0
  visibility_timeout_seconds = 120
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq_queue_gravar_status_processamento.arn
    maxReceiveCount     = 4
  })


  tags = {
    Environment = "production"
  }
}

resource "aws_sqs_queue" "dlq_queue_gravar_status_processamento" {
  name = "dlq-gravar-status-processamento"
}

resource "aws_sqs_queue_redrive_allow_policy" "queue_gravar_status_processamento_redrive_allow_policy" {
  queue_url = aws_sqs_queue.dlq_queue_gravar_status_processamento.id

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.queue_gravar_status_processamento.arn]
  })
}

# ---------------------------------------------------------------------------

resource "aws_lambda_event_source_mapping" "sqs_to_lambda_integration" {
  event_source_arn = aws_sqs_queue.queue_gravar_status_processamento.arn
  function_name    = "hackathon-status-processamento"
}