resource "aws_dynamodb_table" "videos" {
  name         = "videos"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "nome_video"
    type = "S"
  }

  attribute {
    name = "nome_usuario"
    type = "S"
  }

  hash_key  = "nome_video"
  range_key = "nome_usuario"

  tags = {
    Environment = "production"
    Project     = "video-platform"
  }
}

resource "aws_dynamodb_table" "status_processamento" {
  name         = "status_processamento"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "nome_usuario"
    type = "S"
  }

  attribute {
    name = "nome_video"
    type = "S"
  }

  hash_key  = "nome_usuario"
  range_key = "nome_video"

  tags = {
    Environment = "production"
    Project     = "video-platform"
  }
}