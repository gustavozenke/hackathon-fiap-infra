resource "aws_sqs_queue" "queue_inicio_processamento" {
  name                      = "sqs-inicio-processamento"
  sqs_managed_sse_enabled   = true
  delay_seconds             = 0
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 0
  visibility_timeout_seconds = 120
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
  visibility_timeout_seconds = 900
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

resource "aws_lambda_event_source_mapping" "sqs_to_lambda_status_processamento_integration" {
  event_source_arn = aws_sqs_queue.queue_gravar_status_processamento.arn
  function_name    = "hackathon-status-processamento"
}

# ---------------------------------------------------------------------------

resource "aws_lambda_event_source_mapping" "sqs_to_lambda_inicio_processamento_integration" {
  event_source_arn = aws_sqs_queue.queue_inicio_processamento.arn
  function_name    = "hackathon-inicio-processamento"
}

# ---------------------------------------------------------------------------

resource "aws_s3_bucket" "access_logs_bucket_zipped_frames" {
  bucket = "bucket-logs-hackathon-fiap-zipped-frames"
  tags = {
    Environment = "Logging"
  }
}

resource "aws_s3_bucket_versioning" "access_logs_bucket_zipped_frames" {
  bucket = aws_s3_bucket.access_logs_bucket_zipped_frames.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs_encryption_bucket_zipped_frames" {
  bucket = aws_s3_bucket.access_logs_bucket_zipped_frames.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "bucket_logs_public_access_zip_frames" {
  bucket = aws_s3_bucket.access_logs_bucket_zipped_frames.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "bucket_zipped_frames" {
  bucket = "bucket-hackathon-fiap-zipped-frames"
  tags = {
    Environment = "Production"
  }
}

resource "aws_s3_bucket_versioning" "bucket_zipped_frames_versioning" {
  bucket = aws_s3_bucket.bucket_zipped_frames.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_zipped_frames_encryption" {
  bucket = aws_s3_bucket.bucket_zipped_frames.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_s3_bucket_logging" "bucket_zipped_frames_logging" {
  bucket        = aws_s3_bucket.bucket_zipped_frames.id
  target_bucket = aws_s3_bucket.access_logs_bucket_zipped_frames.id
  target_prefix = "logs/"
}

resource "aws_s3_bucket_public_access_block" "bucket_zipped_frames_public_access" {
  bucket = aws_s3_bucket.bucket_zipped_frames.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


resource "aws_s3_bucket_lifecycle_configuration" "bucket_zipped_frames_lifecycle" {
  bucket = aws_s3_bucket.bucket_zipped_frames.id

  rule {
    id     = "auto-archive"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}

output "bucket_zipped_frames_arn" {
  value = aws_s3_bucket.bucket_zipped_frames.arn
}

output "bucket_zipped_frames_log_arn" {
  value = aws_s3_bucket.access_logs_bucket_zipped_frames.arn
}
