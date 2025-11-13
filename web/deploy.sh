#!/bin/bash

###############################################################################
# Monitor Legal Documents Deployment Script
###############################################################################
#
# This script uploads privacy.html and terms.html to S3 and invalidates
# the CloudFront cache for immediate updates.
#
# Prerequisites:
# - AWS CLI installed and configured
# - S3 bucket created (e.g., Monitor-app-legal-docs)
# - CloudFront distribution created
#
# Usage:
#   ./deploy.sh
#
###############################################################################

set -e  # Exit on error

# Configuration (CHANGE THESE VALUES)
BUCKET_NAME="Monitor-app-legal-docs"
DISTRIBUTION_ID=""  # Add your CloudFront distribution ID here (e.g., E1234ABCDEF)
AWS_REGION="us-east-1"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo -e "${RED}Error: AWS CLI is not installed.${NC}"
    echo "Install it with: brew install awscli"
    exit 1
fi

# Check if distribution ID is set
if [ -z "$DISTRIBUTION_ID" ]; then
    echo -e "${YELLOW}Warning: DISTRIBUTION_ID is not set in deploy.sh${NC}"
    echo "CloudFront cache will NOT be invalidated (updates may take 24 hours)"
    echo ""
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check if files exist
if [ ! -f "privacy.html" ]; then
    echo -e "${RED}Error: privacy.html not found${NC}"
    exit 1
fi

if [ ! -f "terms.html" ]; then
    echo -e "${RED}Error: terms.html not found${NC}"
    exit 1
fi

echo -e "${GREEN}Starting deployment...${NC}"
echo ""

# Upload files to S3
echo "📦 Uploading privacy.html to S3..."
aws s3 cp privacy.html "s3://$BUCKET_NAME/privacy.html" \
    --region "$AWS_REGION" \
    --content-type "text/html; charset=utf-8" \
    --cache-control "max-age=3600" \
    --metadata-directive REPLACE

echo "📦 Uploading terms.html to S3..."
aws s3 cp terms.html "s3://$BUCKET_NAME/terms.html" \
    --region "$AWS_REGION" \
    --content-type "text/html; charset=utf-8" \
    --cache-control "max-age=3600" \
    --metadata-directive REPLACE

echo -e "${GREEN}✓ Files uploaded successfully${NC}"
echo ""

# Invalidate CloudFront cache (if distribution ID is set)
if [ -n "$DISTRIBUTION_ID" ]; then
    echo "🔄 Invalidating CloudFront cache..."
    INVALIDATION_ID=$(aws cloudfront create-invalidation \
        --distribution-id "$DISTRIBUTION_ID" \
        --paths "/privacy.html" "/terms.html" \
        --query 'Invalidation.Id' \
        --output text)

    echo -e "${GREEN}✓ Invalidation created: $INVALIDATION_ID${NC}"
    echo "   Cache will be cleared in 1-2 minutes"
else
    echo -e "${YELLOW}⚠ Skipping CloudFront invalidation (DISTRIBUTION_ID not set)${NC}"
    echo "   Changes may take up to 24 hours to appear"
fi

echo ""
echo -e "${GREEN}🎉 Deployment complete!${NC}"
echo ""
echo "Test your deployment:"
echo "  https://Monitor.app/privacy"
echo "  https://Monitor.app/terms"
echo ""
