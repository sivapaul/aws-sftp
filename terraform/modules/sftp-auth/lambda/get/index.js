const AWS = require("aws-sdk");
const dynamodb = new AWS.DynamoDB({
  region: "eu-west-1",
  apiVersion: "2012-08-10",
});

exports.handler = (event, context, callback) => {
  const accessToken = event["queryStringParameters"]["accessToken"];
  const params = {
    TableName: process.env.DYNAMO_TABLE,
  };
  dynamodb.scan(params, function (err, data) {
    if (err) {
      console.log(err);
      callback(err);
    } else {
      const items = data.Items.map((dataField) => {
        return {
          username: dataField.username.S,
          accountseq: dataField.accountseq.S,
        };
      });
      const response = {
        isBase64Encoded: false,
        statusCode: 200,
        headers: {
          "Access-Control-Allow-Origin": "*",
        },
        body: JSON.stringify(items),
      };
      console.log(response);
      callback(null, response);
    }
  });
};
