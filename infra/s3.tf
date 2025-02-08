resource "aws_s3_bucket" "access_logs_bucket_raw_videos" {
  bucket = "bucket-logs-hackathon-fiap-raw-videos"
  tags = {
    Environment = "Logging"
  }
}

resource "aws_s3_bucket_versioning" "access_logs_versioning" {
  bucket = aws_s3_bucket.access_logs_bucket_raw_videos.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs_encryption" {
  bucket = aws_s3_bucket.access_logs_bucket_raw_videos.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "bucket_logs_public_access" {
  bucket = aws_s3_bucket.access_logs_bucket_raw_videos.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "bucket_raw_videos" {
  bucket = "bucket-hackathon-fiap-raw-videos"
  tags = {
    Environment = "Production"
  }
}

resource "aws_s3_bucket_versioning" "bucket_raw_videos_versioning" {
  bucket = aws_s3_bucket.bucket_raw_videos.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_raw_videos_encryption" {
  bucket = aws_s3_bucket.bucket_raw_videos.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_s3_bucket_logging" "bucket_raw_videos_logging" {
  bucket        = aws_s3_bucket.bucket_raw_videos.id
  target_bucket = aws_s3_bucket.access_logs_bucket_raw_videos.id
  target_prefix = "logs/"
}

resource "aws_s3_bucket_public_access_block" "bucket_raw_videos_public_access" {
  bucket = aws_s3_bucket.bucket_raw_videos.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


resource "aws_s3_bucket_lifecycle_configuration" "bucket_raw_videos_lifecycle" {
  bucket = aws_s3_bucket.bucket_raw_videos.id

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

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket_raw_videos.id

  queue {
    queue_arn     = aws_sqs_queue.queue_inicio_processamento.arn
    events        = ["s3:ObjectCreated:*"]
  }

  depends_on = [
    aws_sqs_queue.queue_inicio_processamento,
    aws_sqs_queue_policy.queue_policy_inicio_processamento
  ]
}

output "bucket_raw_videos_arn" {
  value = aws_s3_bucket.bucket_raw_videos.arn
}

output "bucket_raw_videos_log_arn" {
  value = aws_s3_bucket.access_logs_bucket_raw_videos.arn
}

## ------------------------------------------------------------------------------------------------------

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
