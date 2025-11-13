# DynamoDB Table for Feedback Storage

resource "aws_dynamodb_table" "feedback" {
  name         = "${var.project_name}-feedback-${var.environment}"
  billing_mode = var.dynamodb_billing_mode
  hash_key     = "feedbackId"
  range_key    = "timestamp"

  attribute {
    name = "feedbackId"
    type = "S" # String
  }

  attribute {
    name = "timestamp"
    type = "S" # String (ISO 8601 format)
  }

  attribute {
    name = "type"
    type = "S" # Feedback type (bug_report, feature_request, general_feedback)
  }

  # Global Secondary Index for querying by type
  global_secondary_index {
    name            = "TypeIndex"
    hash_key        = "type"
    range_key       = "timestamp"
    projection_type = "ALL"
  }

  # Enable point-in-time recovery for backup
  point_in_time_recovery {
    enabled = true
  }

  # Server-side encryption
  server_side_encryption {
    enabled = true
  }

  # Enable deletion protection in production
  deletion_protection_enabled = var.environment == "prod" ? true : false

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-feedback-${var.environment}"
    }
  )
}

# CloudWatch alarm for DynamoDB errors
resource "aws_cloudwatch_metric_alarm" "dynamodb_errors" {
  alarm_name          = "${var.project_name}-dynamodb-errors-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "UserErrors"
  namespace           = "AWS/DynamoDB"
  period              = 300 # 5 minutes
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "Alert when DynamoDB user errors exceed threshold"
  alarm_actions       = [] # Add SNS topic ARN here if you want email alerts

  dimensions = {
    TableName = aws_dynamodb_table.feedback.name
  }

  tags = var.tags
}
