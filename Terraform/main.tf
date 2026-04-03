provider "aws" {
  region = var.aws_region
}

# 1. สร้าง DynamoDB Table
resource "aws_dynamodb_table" "app_db" {
  name           = "${var.project_name}-Table"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S" # String
  }

  tags = {
    Name        = "${var.project_name}-Table"
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}

# 2. สร้าง S3 Bucket สำหรับเก็บ Lambda Code
resource "aws_s3_bucket" "lambda_assets" {
  bucket = "${lower(var.project_name)}-assets-${random_id.suffix.hex}"
}

resource "random_id" "suffix" {
  byte_length = 4
}