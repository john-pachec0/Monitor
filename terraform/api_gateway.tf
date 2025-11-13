# API Gateway Configuration

# API Gateway Account (sets CloudWatch Logs role for entire AWS account)
resource "aws_api_gateway_account" "main" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_cloudwatch.arn
}

# REST API
resource "aws_api_gateway_rest_api" "feedback" {
  name        = "${var.project_name}-api-${var.environment}"
  description = "Untwist Feedback API"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = var.tags
}

# /feedback resource
resource "aws_api_gateway_resource" "feedback" {
  rest_api_id = aws_api_gateway_rest_api.feedback.id
  parent_id   = aws_api_gateway_rest_api.feedback.root_resource_id
  path_part   = "feedback"
}

# POST method for /feedback
resource "aws_api_gateway_method" "feedback_post" {
  rest_api_id   = aws_api_gateway_rest_api.feedback.id
  resource_id   = aws_api_gateway_resource.feedback.id
  http_method   = "POST"
  authorization = "NONE"
  api_key_required = var.enable_api_key
}

# Integration with Lambda
resource "aws_api_gateway_integration" "feedback_post" {
  rest_api_id             = aws_api_gateway_rest_api.feedback.id
  resource_id             = aws_api_gateway_resource.feedback.id
  http_method             = aws_api_gateway_method.feedback_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.feedback_handler.invoke_arn
}

# CORS for /feedback
resource "aws_api_gateway_method" "feedback_options" {
  rest_api_id   = aws_api_gateway_rest_api.feedback.id
  resource_id   = aws_api_gateway_resource.feedback.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "feedback_options" {
  rest_api_id = aws_api_gateway_rest_api.feedback.id
  resource_id = aws_api_gateway_resource.feedback.id
  http_method = aws_api_gateway_method.feedback_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "feedback_options" {
  rest_api_id = aws_api_gateway_rest_api.feedback.id
  resource_id = aws_api_gateway_resource.feedback.id
  http_method = aws_api_gateway_method.feedback_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "feedback_options" {
  rest_api_id = aws_api_gateway_rest_api.feedback.id
  resource_id = aws_api_gateway_resource.feedback.id
  http_method = aws_api_gateway_method.feedback_options.http_method
  status_code = aws_api_gateway_method_response.feedback_options.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# /admin/feedback resource for admin dashboard
resource "aws_api_gateway_resource" "admin" {
  rest_api_id = aws_api_gateway_rest_api.feedback.id
  parent_id   = aws_api_gateway_rest_api.feedback.root_resource_id
  path_part   = "admin"
}

resource "aws_api_gateway_resource" "admin_feedback" {
  rest_api_id = aws_api_gateway_rest_api.feedback.id
  parent_id   = aws_api_gateway_resource.admin.id
  path_part   = "feedback"
}

# GET method for /admin/feedback
resource "aws_api_gateway_method" "admin_feedback_get" {
  rest_api_id   = aws_api_gateway_rest_api.feedback.id
  resource_id   = aws_api_gateway_resource.admin_feedback.id
  http_method   = "GET"
  authorization = "NONE"
  api_key_required = true # Always require API key for admin endpoints
}

resource "aws_api_gateway_integration" "admin_feedback_get" {
  rest_api_id             = aws_api_gateway_rest_api.feedback.id
  resource_id             = aws_api_gateway_resource.admin_feedback.id
  http_method             = aws_api_gateway_method.admin_feedback_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.admin_handler.invoke_arn
}

# CORS for /admin/feedback
resource "aws_api_gateway_method" "admin_feedback_options" {
  rest_api_id   = aws_api_gateway_rest_api.feedback.id
  resource_id   = aws_api_gateway_resource.admin_feedback.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "admin_feedback_options" {
  rest_api_id = aws_api_gateway_rest_api.feedback.id
  resource_id = aws_api_gateway_resource.admin_feedback.id
  http_method = aws_api_gateway_method.admin_feedback_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "admin_feedback_options" {
  rest_api_id = aws_api_gateway_rest_api.feedback.id
  resource_id = aws_api_gateway_resource.admin_feedback.id
  http_method = aws_api_gateway_method.admin_feedback_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "admin_feedback_options" {
  rest_api_id = aws_api_gateway_rest_api.feedback.id
  resource_id = aws_api_gateway_resource.admin_feedback.id
  http_method = aws_api_gateway_method.admin_feedback_options.http_method
  status_code = aws_api_gateway_method_response.admin_feedback_options.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "feedback" {
  rest_api_id = aws_api_gateway_rest_api.feedback.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.feedback.id,
      aws_api_gateway_method.feedback_post.id,
      aws_api_gateway_integration.feedback_post.id,
      aws_api_gateway_resource.admin_feedback.id,
      aws_api_gateway_method.admin_feedback_get.id,
      aws_api_gateway_integration.admin_feedback_get.id,
      aws_api_gateway_method.admin_feedback_options.id,
      aws_api_gateway_integration.admin_feedback_options.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# API Gateway Stage
resource "aws_api_gateway_stage" "feedback" {
  deployment_id = aws_api_gateway_deployment.feedback.id
  rest_api_id   = aws_api_gateway_rest_api.feedback.id
  stage_name    = var.environment

  # Enable access logging
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      resourcePath   = "$context.resourcePath"
      status         = "$context.status"
      protocol       = "$context.protocol"
      responseLength = "$context.responseLength"
    })
  }

  tags = var.tags

  depends_on = [aws_api_gateway_account.main]
}

# Method Settings for throttling
resource "aws_api_gateway_method_settings" "feedback" {
  rest_api_id = aws_api_gateway_rest_api.feedback.id
  stage_name  = aws_api_gateway_stage.feedback.stage_name
  method_path = "*/*"

  settings {
    throttling_rate_limit  = var.rate_limit
    throttling_burst_limit = var.burst_limit
    logging_level          = "INFO"
    data_trace_enabled     = true
    metrics_enabled        = true
  }
}

# CloudWatch Log Group for API Gateway
resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/${var.project_name}-${var.environment}"
  retention_in_days = var.cloudwatch_retention_days

  tags = var.tags
}

# API Key for feedback submission (iOS app)
resource "aws_api_gateway_api_key" "feedback" {
  count = var.enable_api_key ? 1 : 0
  name  = "${var.project_name}-api-key-${var.environment}"

  tags = var.tags
}

# Admin API Key (separate, more restricted)
resource "aws_api_gateway_api_key" "admin" {
  name = "${var.project_name}-admin-api-key-${var.environment}"

  tags = merge(
    var.tags,
    {
      Purpose = "Admin dashboard access only"
    }
  )
}

# Usage Plan for feedback submission
resource "aws_api_gateway_usage_plan" "feedback" {
  count = var.enable_api_key ? 1 : 0
  name  = "${var.project_name}-usage-plan-${var.environment}"

  api_stages {
    api_id = aws_api_gateway_rest_api.feedback.id
    stage  = aws_api_gateway_stage.feedback.stage_name
  }

  quota_settings {
    limit  = 10000
    period = "MONTH"
  }

  throttle_settings {
    rate_limit  = var.rate_limit
    burst_limit = var.burst_limit
  }

  tags = var.tags
}

# Usage Plan for admin dashboard (more restrictive)
resource "aws_api_gateway_usage_plan" "admin" {
  name = "${var.project_name}-admin-usage-plan-${var.environment}"

  api_stages {
    api_id = aws_api_gateway_rest_api.feedback.id
    stage  = aws_api_gateway_stage.feedback.stage_name
  }

  quota_settings {
    limit  = 1000
    period = "MONTH"
  }

  throttle_settings {
    rate_limit  = 5   # Lower rate limit for admin
    burst_limit = 10
  }

  tags = merge(
    var.tags,
    {
      Purpose = "Admin dashboard access only"
    }
  )
}

# Link feedback API Key to feedback Usage Plan
resource "aws_api_gateway_usage_plan_key" "feedback" {
  count         = var.enable_api_key ? 1 : 0
  key_id        = aws_api_gateway_api_key.feedback[0].id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.feedback[0].id
}

# Link admin API Key to admin Usage Plan
resource "aws_api_gateway_usage_plan_key" "admin" {
  key_id        = aws_api_gateway_api_key.admin.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.admin.id
}
