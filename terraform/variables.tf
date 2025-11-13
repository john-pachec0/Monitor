# Terraform Variables for Untwist Feedback Infrastructure

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "untwist"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1" # Required for ACM certificates for API Gateway
}

variable "domain_name" {
  description = "Root domain name (e.g., untwist.app)"
  type        = string
  default     = "untwist.app"
}

variable "api_subdomain" {
  description = "API subdomain (e.g., api)"
  type        = string
  default     = "api"
}

variable "notification_email" {
  description = "Email address to receive feedback notifications"
  type        = string
  # Set via terraform.tfvars or TF_VAR_notification_email environment variable
}

variable "from_email" {
  description = "SES verified email address for sending notifications"
  type        = string
  # Set via terraform.tfvars or TF_VAR_from_email environment variable
}

variable "enable_api_key" {
  description = "Enable API key authentication for API Gateway"
  type        = bool
  default     = true
}

variable "rate_limit" {
  description = "API Gateway rate limit (requests per second)"
  type        = number
  default     = 10
}

variable "burst_limit" {
  description = "API Gateway burst limit"
  type        = number
  default     = 20
}

variable "lambda_memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 256
}

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 10
}

variable "dynamodb_billing_mode" {
  description = "DynamoDB billing mode (PROVISIONED or PAY_PER_REQUEST)"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "cloudwatch_retention_days" {
  description = "CloudWatch Logs retention in days"
  type        = number
  default     = 30
}

variable "enable_xray_tracing" {
  description = "Enable AWS X-Ray tracing for Lambda"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project   = "Untwist"
    ManagedBy = "Terraform"
    Purpose   = "Feedback API"
  }
}
