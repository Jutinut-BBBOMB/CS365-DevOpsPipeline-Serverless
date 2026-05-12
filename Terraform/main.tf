provider "aws" {
  region = var.aws_region
}

# สร้าง DynamoDB Table
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

# สร้าง S3 Bucket สำหรับเก็บ Lambda Code
resource "aws_s3_bucket" "lambda_assets" {
  bucket = "${lower(var.project_name)}-assets-${random_id.suffix.hex}"
}

resource "random_id" "suffix" {
  byte_length = 4
}

# เตรียมไฟล์โค้ด Lambda เป็น .zip
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_code"
  output_path = "${path.module}/lambda_function.zip"
}

# เรียกใช้ LabRole ของบัญชี AWS Academy
data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

# สร้าง Lambda Function
resource "aws_lambda_function" "student_api_lambda" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.project_name}-Function"
  role             = data.aws_iam_role.lab_role.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.app_db.name
    }
  }
}

# สร้าง API Gateway (HTTP API)
resource "aws_apigatewayv2_api" "http_api" {
  name          = "${var.project_name}-API"
  protocol_type = "HTTP"
  
  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_headers = ["Content-Type"]
  }
}

# เชื่อมต่อ API Gateway เข้ากับ Lambda
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.student_api_lambda.invoke_arn
}

# สร้าง Routes
resource "aws_apigatewayv2_route" "get_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /student-api/getStudent"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "post_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /student-api/addStudent"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# สร้าง Stage และเปิด Auto-deploy
resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

# ให้สิทธิ์ API Gateway ให้สั่งรัน Lambda ได้
resource "aws_lambda_permission" "api_gw_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.student_api_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

# แสดงผล URL หลังสร้างเสร็จ
output "api_endpoint" {
  description = "URL ของ API Gateway สำหรับนำไปใส่ในแอปหน้าบ้าน"
  value       = aws_apigatewayv2_api.http_api.api_endpoint
}