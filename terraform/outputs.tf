# Terraform Outputs

output "api_endpoint" {
  description = "API Gateway endpoint URL (before custom domain)"
  value       = aws_api_gateway_stage.feedback.invoke_url
}

output "custom_domain_url" {
  description = "Custom domain URL for API"
  value       = "https://${aws_api_gateway_domain_name.api.domain_name}"
}

output "feedback_endpoint" {
  description = "Full feedback submission endpoint"
  value       = "https://${aws_api_gateway_domain_name.api.domain_name}/feedback"
}

output "admin_endpoint" {
  description = "Admin dashboard API endpoint"
  value       = "https://${aws_api_gateway_domain_name.api.domain_name}/admin/feedback"
}

output "api_key" {
  description = "API Gateway API key for feedback submission (iOS app)"
  value       = var.enable_api_key ? aws_api_gateway_api_key.feedback[0].value : "API key not enabled"
  sensitive   = true
}

output "admin_api_key" {
  description = "Admin API key for dashboard access (keep this secret!)"
  value       = aws_api_gateway_api_key.admin.value
  sensitive   = true
}

output "dynamodb_table_name" {
  description = "DynamoDB table name for feedback storage"
  value       = aws_dynamodb_table.feedback.name
}

output "lambda_function_names" {
  description = "Lambda function names"
  value = {
    feedback_handler = aws_lambda_function.feedback_handler.function_name
    admin_handler    = aws_lambda_function.admin_handler.function_name
  }
}

output "cloudwatch_log_groups" {
  description = "CloudWatch Log Group names for monitoring"
  value = {
    feedback_handler = aws_cloudwatch_log_group.feedback_handler.name
    admin_handler    = aws_cloudwatch_log_group.admin_handler.name
    api_gateway      = aws_cloudwatch_log_group.api_gateway.name
  }
}

output "domain_validation_records" {
  description = "DNS records needed for ACM certificate validation (for Namecheap setup)"
  value = {
    for dvo in aws_acm_certificate.api.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }
}

output "api_gateway_domain_target" {
  description = "Target for DNS CNAME record (use this in Namecheap)"
  value = {
    regional_domain = aws_api_gateway_domain_name.api.regional_domain_name
    regional_zone   = aws_api_gateway_domain_name.api.regional_zone_id
  }
}

output "certificate_validation_instructions" {
  description = "Instructions for validating ACM certificate in Namecheap"
  value = var.use_route53 ? "Using Route 53 - certificate auto-validated" : <<-EOT

  ⚠️  CERTIFICATE VALIDATION REQUIRED ⚠️

  Your ACM certificate needs DNS validation. Add this CNAME record to Namecheap:

  ${join("\n", [for dvo in aws_acm_certificate.api.domain_validation_options :
    "Type: CNAME\nHost: ${replace(dvo.resource_record_name, ".${var.domain_name}.", "")}\nValue: ${dvo.resource_record_value}\nTTL: Automatic"
  ])}

  After adding to Namecheap:
  1. Wait 5-15 minutes for DNS propagation
  2. The certificate will auto-validate
  3. Then you can use the custom domain

  Check status: AWS Console → Certificate Manager → us-east-1

  EOT
}

output "next_steps" {
  description = "Next steps after Terraform apply"
  value       = <<-EOT

  ========================================
  Untwist Feedback API - Deployment Complete!
  ========================================

  API Endpoints:
  - Feedback: https://${aws_api_gateway_domain_name.api.domain_name}/feedback
  - Admin: https://${aws_api_gateway_domain_name.api.domain_name}/admin/feedback

  API Keys:
  ${var.enable_api_key ? "- Feedback (iOS app): Run 'terraform output -raw api_key'" : ""}
  - Admin (dashboard): Run 'terraform output -raw admin_api_key'

  Next Steps:
  -----------

  ${!var.use_route53 ? "⚠️  1. VALIDATE CERTIFICATE (REQUIRED):\n     Run: terraform output certificate_validation_instructions\n" : ""}

  ${!var.use_route53 ? "2" : "1"}. DNS Configuration (Namecheap):
     - Add CNAME record:
       Name: ${var.api_subdomain}
       Value: ${aws_api_gateway_domain_name.api.regional_domain_name}

  ${!var.use_route53 ? "3" : "2"}. Verify SES Email Addresses:
     - Check your inbox for verification emails
     - Click verification links for:
       * ${var.from_email}
       ${var.notification_email != var.from_email ? "* ${var.notification_email}" : ""}

  ${!var.use_route53 ? "4" : "3"}. Test the API:
     curl -X POST https://${aws_api_gateway_domain_name.api.domain_name}/feedback \
       -H "Content-Type: application/json" \
       ${var.enable_api_key ? "-H \"x-api-key: YOUR-API-KEY\" \\" : ""}\
       -d '{
         "feedback": "Test feedback",
         "type": "general_feedback",
         "timestamp": "2025-11-08T12:00:00Z"
       }'

  ${!var.use_route53 ? "5" : "4"}. Update iOS App:
     - Endpoint is already set correctly in FeedbackService.swift
     ${var.enable_api_key ? "- Add API key header: request.setValue(apiKey, forHTTPHeaderField: \"x-api-key\")" : ""}

  ${!var.use_route53 ? "6" : "5"}. Monitor:
     - CloudWatch Logs: ${aws_cloudwatch_log_group.api_gateway.name}
     - DynamoDB Table: ${aws_dynamodb_table.feedback.name}

  Resources Created:
  - API Gateway: ${aws_api_gateway_rest_api.feedback.name}
  - Lambda Functions: 2 (feedback-handler, admin-handler)
  - DynamoDB Table: ${aws_dynamodb_table.feedback.name}
  - Custom Domain: ${aws_api_gateway_domain_name.api.domain_name}

  ========================================
  EOT
}
