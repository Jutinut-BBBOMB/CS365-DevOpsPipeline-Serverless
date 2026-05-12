import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, ScanCommand, PutCommand } from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({ region: "us-east-1" });
const dynamo = DynamoDBDocumentClient.from(client);
const tableName = process.env.TABLE_NAME;

export const handler = async (event) => {
  const headers = {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type"
  };

  try {
    const routeKey = event.routeKey;

    if (routeKey === "GET /student-api/getStudent") {
      const body = await dynamo.send(new ScanCommand({ TableName: tableName }));
      return { statusCode: 200, headers, body: JSON.stringify(body.Items) };

    } else if (routeKey === "POST /student-api/addStudent") {
      const requestJSON = JSON.parse(event.body);
      await dynamo.send(new PutCommand({
        TableName: tableName,
        Item: {
          id: requestJSON.roll_number,
          roll_number: requestJSON.roll_number,
          student_name: requestJSON.student_name,
          student_class: requestJSON.student_class
        }
      }));
      return { statusCode: 200, headers, body: JSON.stringify({ message: "Student added successfully!" }) };

    } else {
      return { statusCode: 400, headers, body: JSON.stringify({ message: "Unsupported route" }) };
    }
  } catch (err) {
    console.error(err);
    return { statusCode: 500, headers, body: JSON.stringify({ error: err.message }) };
  }
};