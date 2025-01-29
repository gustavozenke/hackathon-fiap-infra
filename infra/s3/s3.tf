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

resource "aws_s3_bucket_public_access_block" "logs_public_access" {
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

resource "aws_kms_key" "s3_kms_key" {
  description             = "KMS key for S3 bucket encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_raw_videos_encryption" {
  bucket = aws_s3_bucket.bucket_raw_videos.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_kms_key.arn
      sse_algorithm     = "aws:kms"
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

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "bucket_raw_videos_bucket_policy" {
  bucket = aws_s3_bucket.bucket_raw_videos.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowSSLRequestsOnly"
        Effect = "Deny"
        Principal = "*"
        Action = "s3:*"
        Resource = [
          aws_s3_bucket.bucket_raw_videos.arn,
          "${aws_s3_bucket.bucket_raw_videos.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
      {
        Sid    = "EnforceEncryption"
        Effect = "Deny"
        Principal = "*"
        Action = "s3:PutObject"
        Resource = "${aws_s3_bucket.bucket_raw_videos.arn}/*"
        Condition = {
          Null = {
            "s3:x-amz-server-side-encryption" = "true"
          }
        }
      }
    ]
  })
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

output "bucket_raw_videos_arn" {
  value = aws_s3_bucket.bucket_raw_videos.arn
}

output "bucket_raw_videos_log_arn" {
  value = aws_s3_bucket.access_logs_bucket_raw_videos.arn
}