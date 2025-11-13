# SES (Simple Email Service) Configuration

# Note: SES email addresses must be manually verified in the AWS Console
# This configuration creates the necessary resources but verification is manual

# SES Email Identity for FROM address
resource "aws_ses_email_identity" "from_email" {
  email = var.from_email
}

# SES Email Identity for NOTIFICATION address (if different)
resource "aws_ses_email_identity" "notification_email" {
  count = var.notification_email != var.from_email ? 1 : 0
  email = var.notification_email
}

# SES Configuration Set (for tracking bounces/complaints)
resource "aws_ses_configuration_set" "feedback" {
  name = "${var.project_name}-${var.environment}"

  # Enable reputation metrics
  reputation_metrics_enabled = true

  # Enable sending
  sending_enabled = true
}

# CloudWatch Event Destination for bounces
resource "aws_ses_event_destination" "cloudwatch" {
  name                   = "cloudwatch-destination"
  configuration_set_name = aws_ses_configuration_set.feedback.name
  enabled                = true
  matching_types         = ["bounce", "complaint", "delivery"]

  cloudwatch_destination {
    default_value  = "default"
    dimension_name = "ses:configuration-set"
    value_source   = "messageTag"
  }
}

# SNS Topic for bounce/complaint notifications (optional)
resource "aws_sns_topic" "ses_notifications" {
  count = var.enable_ses_notifications ? 1 : 0
  name  = "${var.project_name}-ses-notifications-${var.environment}"

  tags = var.tags
}

resource "aws_sns_topic_subscription" "ses_email" {
  count     = var.enable_ses_notifications ? 1 : 0
  topic_arn = aws_sns_topic.ses_notifications[0].arn
  protocol  = "email"
  endpoint  = var.notification_email
}

variable "enable_ses_notifications" {
  description = "Enable SNS notifications for SES bounces and complaints"
  type        = bool
  default     = false
}

# Output instructions for email verification
output "ses_verification_instructions" {
  value = <<-EOT

  IMPORTANT: SES Email Verification Required
  ==========================================

  Please verify the following email addresses in the AWS Console:

  1. Go to AWS Console → SES → Verified identities
  2. Click on the email address to verify:
     - FROM: ${var.from_email}
     ${var.notification_email != var.from_email ? "- NOTIFICATION: ${var.notification_email}" : ""}

  3. Check your email inbox for verification emails from AWS
  4. Click the verification link in each email

  Note: SES starts in "sandbox mode" which only allows sending to verified addresses.
  To send to any address, request production access:

  AWS Console → SES → Account dashboard → Request production access

  EOT
}
