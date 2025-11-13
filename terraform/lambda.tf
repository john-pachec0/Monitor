# Lambda Functions

# Package Lambda function code
data "archive_file" "feedback_handler" {
  type        = "zip"
  source_file = "./aws-lambda-feedback-handler.js"
  output_path = "${path.module}/lambda-packages/feedback-handler.zip"
}

data "archive_file" "admin_handler" {
  type        = "zip"
  source_file = "./aws-lambda-admin-handler.js"
  output_path = "${path.module}/lambda-packages/admin-handler.zip"
}

# Feedback Handler Lambda Function
resource "aws_lambda_function" "feedback_handler" {
  filename         = data.archive_file.feedback_handler.output_path
  function_name    = "${var.project_name}-feedback-handler-${var.environment}"
  role            = aws_iam_role.lambda_execution.arn
  handler         = "aws-lambda-feedback-handler.handler"
  source_code_hash = data.archive_file.feedback_handler.output_base64sha256
  runtime         = "nodejs20.x"
  memory_size     = var.lambda_memory_size
  timeout         = var.lambda_timeout
  architectures   = ["arm64"] # Graviton2 (cheaper and faster)

  environment {
    variables = {
      DYNAMODB_TABLE     = aws_dynamodb_table.feedback.name
      NOTIFICATION_EMAIL = var.notification_email
      FROM_EMAIL         = var.from_email
      ENVIRONMENT        = var.environment
    }
  }

  tracing_config {
    mode = var.enable_xray_tracing ? "Active" : "PassThrough"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-feedback-handler-${var.environment}"
    }
  )
}

# Admin Handler Lambda Function
resource "aws_lambda_function" "admin_handler" {
  filename         = data.archive_file.admin_handler.output_path
  function_name    = "${var.project_name}-admin-handler-${var.environment}"
  role            = aws_iam_role.lambda_execution.arn
  handler         = "aws-lambda-admin-handler.handler"
  source_code_hash = data.archive_file.admin_handler.output_base64sha256
  runtime         = "nodejs20.x"
  memory_size     = var.lambda_memory_size
  timeout         = var.lambda_timeout
  architectures   = ["arm64"]

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.feedback.name
      ENVIRONMENT    = var.environment
    }
  }

  tracing_config {
    mode = var.enable_xray_tracing ? "Active" : "PassThrough"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-admin-handler-${var.environment}"
    }
  )
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "feedback_handler" {
  name              = "/aws/lambda/${aws_lambda_function.feedback_handler.function_name}"
  retention_in_days = var.cloudwatch_retention_days

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "admin_handler" {
  name              = "/aws/lambda/${aws_lambda_function.admin_handler.function_name}"
  retention_in_days = var.cloudwatch_retention_days

  tags = var.tags
}

# Lambda Permissions for API Gateway
resource "aws_lambda_permission" "feedback_api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.feedback_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.feedback.execution_arn}/*/*"
}

resource "aws_lambda_permission" "admin_api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.admin_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.feedback.execution_arn}/*/*"
}

# CloudWatch Alarms for Lambda
resource "aws_cloudwatch_metric_alarm" "feedback_handler_errors" {
  alarm_name          = "${var.project_name}-feedback-handler-errors-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "Alert when Lambda errors exceed threshold"
  alarm_actions       = [] # Add SNS topic ARN for notifications

  dimensions = {
    FunctionName = aws_lambda_function.feedback_handler.function_name
  }

  tags = var.tags
}
