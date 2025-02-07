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

##------------------------------------------------------------------------------------

resource "aws_s3_bucket" "public_bucket_zip_frames" {
  bucket = "bucket-hackathon-fiap-zip-frames"
}

resource "aws_s3_bucket_public_access_block" "public_block_bucket_zip_frames" {
  bucket                  = aws_s3_bucket.public_bucket_zip_frames.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public_policy_bucket_zip_frames" {
  bucket = aws_s3_bucket.public_bucket_zip_frames.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.public_bucket_zip_frames.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_acl" "public_acl_bucket_zip_frames" {
  bucket = aws_s3_bucket.public_bucket_zip_frames.id
  acl    = "public-read"
}
