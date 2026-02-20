# CS365 Final Project: Terraform Serverless App Deployment
**กลุ่ม:** Terraform Serverless
## Team Members & Roles(อาจมีการเปลี่ยนแปลง)
**จุติณัฏฐ์ รัตนะมงคลกุล** (6609650228)
**Role:** Infrastructure & Project Lead

**พชร พรพงศ์** (6609650509)
**Role:** Pipeline, Security & Docs 

## Architecture Overview
โปรเจกต์นี้เลือก Replicate ระบบ Serverless บน AWS โดยใช้ Terraform เข้ามาช่วยในส่วนของ Infrastructure
![Architecture Diagram](https://miro.medium.com/v2/resize:fit:4800/format:webp/1*SZI5QIEZEYUUQuB4pQfTjw.gif)

### Technology Stack
- **IaC:** Terraform
- **CI/CD:** CircleCI
- **Compute:** AWS Lambda (Node.js/Python)
- **API:** AWS API Gateway
- **Database:** Amazon DynamoDB
- **Frontend:** AWS Amplify / S3 Static Hosting
- **Security:** AWS IAM

### References
 - Github: https://github.com/AmanPathak-DevOps/Terraform-for-AWS/tree/master/Non-Modularized/AWS-Serverless-Project
 - Blog : https://blog.devops.dev/terraform-deployment-of-awesome-app-on-aws-serverless-services-step-by-step-guide-7241b01770e0
