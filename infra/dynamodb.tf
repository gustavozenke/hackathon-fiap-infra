resource "aws_dynamodb_table" "videos" {
  name         = "videos"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "nom_vid"
    type = "S"
  }

  attribute {
    name = "dat_hor_upl_vid"
    type = "S"
  }

  hash_key  = "nom_vid"
  range_key = "dat_hor_upl_vid"

  tags = {
    Environment = "production"
    Project     = "video-platform"
  }
}