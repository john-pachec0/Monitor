// Untwist Feedback Handler Lambda Function
// Runtime: Node.js 20.x
// Architecture: arm64
// Memory: 256 MB
// Timeout: 10 seconds

const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, PutCommand } = require('@aws-sdk/lib-dynamodb');
const { SESClient, SendEmailCommand } = require('@aws-sdk/client-ses');
const { randomUUID } = require('crypto');

// Initialize AWS clients
const dynamoClient = new DynamoDBClient({ region: process.env.AWS_REGION });
const docClient = DynamoDBDocumentClient.from(dynamoClient);
const sesClient = new SESClient({ region: process.env.AWS_REGION });

// Environment variables (set in Lambda console)
const TABLE_NAME = process.env.DYNAMODB_TABLE || 'untwist-feedback';
const NOTIFICATION_EMAIL = process.env.NOTIFICATION_EMAIL; // Your email
const FROM_EMAIL = process.env.FROM_EMAIL; // Verified SES email

// Valid feedback types
const VALID_TYPES = ['bug_report', 'feature_request', 'general_feedback'];

exports.handler = async (event) => {
  console.log('Received event:', JSON.stringify(event, null, 2));

  try {
    // Parse request body
    let body;
    try {
      body = JSON.parse(event.body || '{}');
    } catch (parseError) {
      return createResponse(400, {
        error: 'Invalid JSON in request body'
      });
    }

    // Validate required fields
    const { feedback, type, diagnostic, timestamp } = body;

    if (!feedback || typeof feedback !== 'string') {
      return createResponse(400, {
        error: 'Missing or invalid "feedback" field'
      });
    }

    if (!type || !VALID_TYPES.includes(type)) {
      return createResponse(400, {
        error: `Invalid "type". Must be one of: ${VALID_TYPES.join(', ')}`
      });
    }

    // Generate unique ID
    const feedbackId = randomUUID();
    const receivedAt = new Date().toISOString();

    // Prepare item for DynamoDB
    const item = {
      feedbackId,
      timestamp: timestamp || receivedAt,
      receivedAt,
      feedback,
      type,
      diagnostic: diagnostic || {},
      status: 'new',
      // Add TTL (optional): auto-delete after 2 years
      ttl: Math.floor(Date.now() / 1000) + (2 * 365 * 24 * 60 * 60)
    };

    // Save to DynamoDB
    await docClient.send(new PutCommand({
      TableName: TABLE_NAME,
      Item: item
    }));

    console.log('Feedback saved to DynamoDB:', feedbackId);

    // Send email notification
    await sendEmailNotification(item);

    // Return success
    return createResponse(200, {
      success: true,
      feedbackId,
      message: 'Feedback received successfully'
    });

  } catch (error) {
    console.error('Error processing feedback:', error);

    return createResponse(500, {
      error: 'Internal server error',
      message: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

async function sendEmailNotification(feedbackItem) {
  if (!NOTIFICATION_EMAIL || !FROM_EMAIL) {
    console.warn('Email not configured. Skipping notification.');
    return;
  }

  const { feedbackId, type, feedback, diagnostic, receivedAt } = feedbackItem;

  // Format diagnostic info
  const diagnosticInfo = diagnostic
    ? `
App Version: ${diagnostic.appVersion || 'N/A'}
iOS Version: ${diagnostic.iosVersion || 'N/A'}
Device: ${diagnostic.device || 'N/A'}
Locale: ${diagnostic.locale || 'N/A'}`
    : 'No diagnostic information provided';

  // Create email
  const emailParams = {
    Source: FROM_EMAIL,
    Destination: {
      ToAddresses: [NOTIFICATION_EMAIL]
    },
    Message: {
      Subject: {
        Data: `[Untwist] New ${formatType(type)} - ${feedbackId.slice(0, 8)}`
      },
      Body: {
        Text: {
          Data: `
New feedback received for Untwist app

Feedback ID: ${feedbackId}
Type: ${formatType(type)}
Received: ${receivedAt}

--- FEEDBACK ---
${feedback}

--- DIAGNOSTIC INFO ---
${diagnosticInfo}

--- ACTIONS ---
View in DynamoDB: https://console.aws.amazon.com/dynamodb/home?region=${process.env.AWS_REGION}#tables:name=${TABLE_NAME}
Filter by feedbackId: ${feedbackId}
          `.trim()
        }
      }
    }
  };

  try {
    await sesClient.send(new SendEmailCommand(emailParams));
    console.log('Email notification sent successfully');
  } catch (emailError) {
    console.error('Failed to send email notification:', emailError);
    // Don't throw - email failure shouldn't fail the request
  }
}

function formatType(type) {
  const typeMap = {
    'bug_report': 'Bug Report',
    'feature_request': 'Feature Request',
    'general_feedback': 'General Feedback'
  };
  return typeMap[type] || type;
}

function createResponse(statusCode, body) {
  return {
    statusCode,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*', // Adjust for production
      'Access-Control-Allow-Headers': 'Content-Type',
      'Access-Control-Allow-Methods': 'POST, OPTIONS'
    },
    body: JSON.stringify(body)
  };
}
