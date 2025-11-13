// Monitor Admin Dashboard Handler Lambda Function
// Runtime: Node.js 20.x
// This provides a READ-ONLY endpoint for the admin dashboard

const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, ScanCommand, QueryCommand } = require('@aws-sdk/lib-dynamodb');

const dynamoClient = new DynamoDBClient({ region: process.env.AWS_REGION });
const docClient = DynamoDBDocumentClient.from(dynamoClient);

const TABLE_NAME = process.env.DYNAMODB_TABLE || 'Monitor-feedback';

exports.handler = async (event) => {
  console.log('Admin request:', JSON.stringify(event, null, 2));

  try {
    // Parse query parameters
    const queryParams = event.queryStringParameters || {};
    const type = queryParams.type;
    const limit = parseInt(queryParams.limit || '100', 10);

    let items;

    if (type && type !== 'all') {
      // Query by type using GSI
      const result = await docClient.send(new QueryCommand({
        TableName: TABLE_NAME,
        IndexName: 'type-timestamp-index',
        KeyConditionExpression: '#type = :type',
        ExpressionAttributeNames: {
          '#type': 'type'
        },
        ExpressionAttributeValues: {
          ':type': type
        },
        Limit: limit,
        ScanIndexForward: false // newest first
      }));
      items = result.Items || [];
    } else {
      // Scan all items
      const result = await docClient.send(new ScanCommand({
        TableName: TABLE_NAME,
        Limit: limit
      }));
      items = result.Items || [];
    }

    // Sort by timestamp (newest first)
    items.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));

    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type, x-api-key',
        'Access-Control-Allow-Methods': 'GET, OPTIONS'
      },
      body: JSON.stringify(items)
    };

  } catch (error) {
    console.error('Error fetching feedback:', error);

    return {
      statusCode: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      },
      body: JSON.stringify({
        error: 'Internal server error',
        message: process.env.NODE_ENV === 'development' ? error.message : undefined
      })
    };
  }
};
