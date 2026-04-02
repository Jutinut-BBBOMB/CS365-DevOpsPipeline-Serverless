variable "aws_region" {
  description = "AWS Region to deploy resources"
  type        = string
  default     = "us-east-1" # เปลี่ยนจาก ap-southeast-1 เป็น us-east-1
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "CS365-Serverless-App"
}