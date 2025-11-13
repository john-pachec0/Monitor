# Route 53 and Custom Domain Configuration

# ACM Certificate for api.untwist.app (must be in us-east-1 for API Gateway)
resource "aws_acm_certificate" "api" {
  domain_name       = "${var.api_subdomain}.${var.domain_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.api_subdomain}.${var.domain_name}"
    }
  )
}

# Data source to get the hosted zone (assumes domain is already in Route 53 or Namecheap)
# If using Namecheap, you'll need to manually create DNS validation records
data "aws_route53_zone" "main" {
  count        = var.use_route53 ? 1 : 0
  name         = var.domain_name
  private_zone = false
}

# DNS validation records (only if using Route 53)
resource "aws_route53_record" "cert_validation" {
  for_each = var.use_route53 ? {
    for dvo in aws_acm_certificate.api.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.main[0].zone_id
}

# ACM Certificate Validation (only auto-validate if using Route 53)
resource "aws_acm_certificate_validation" "api" {
  count           = var.use_route53 ? 1 : 0
  certificate_arn = aws_acm_certificate.api.arn

  validation_record_fqdns = [
    for record in aws_route53_record.cert_validation : record.fqdn
  ]

  timeouts {
    create = "15m"
  }
}

# Custom Domain Name for API Gateway
resource "aws_api_gateway_domain_name" "api" {
  domain_name              = "${var.api_subdomain}.${var.domain_name}"
  regional_certificate_arn = var.use_route53 ? aws_acm_certificate_validation.api[0].certificate_arn : aws_acm_certificate.api.arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = var.tags

  depends_on = [aws_acm_certificate.api]
}

# Base Path Mapping
resource "aws_api_gateway_base_path_mapping" "api" {
  api_id      = aws_api_gateway_rest_api.feedback.id
  stage_name  = aws_api_gateway_stage.feedback.stage_name
  domain_name = aws_api_gateway_domain_name.api.domain_name
}

# Route 53 A Record for Custom Domain (only if using Route 53)
resource "aws_route53_record" "api" {
  count   = var.use_route53 ? 1 : 0
  zone_id = data.aws_route53_zone.main[0].zone_id
  name    = var.api_subdomain
  type    = "A"

  alias {
    name                   = aws_api_gateway_domain_name.api.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.api.regional_zone_id
    evaluate_target_health = false
  }
}

# Variable for Route 53 usage
variable "use_route53" {
  description = "Whether to use Route 53 for DNS (false if using Namecheap)"
  type        = bool
  default     = false
}
