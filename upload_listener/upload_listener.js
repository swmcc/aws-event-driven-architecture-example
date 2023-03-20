const AWS = require('aws-sdk');
const lambda = new AWS.Lambda();

exports.handler = async (event) => {
  const s3Event = event.Records[0].s3;
  const bucket = s3Event.bucket.name;
  const key = s3Event.object.key;

  const params = {
    FunctionName: 'ImageProcessorFunction',
    InvocationType: 'Event',
    Payload: JSON.stringify({
      Records: [{
        s3: {
          bucket: {
            name: bucket
          },
          object: {
            key: key
          }
        }
      }]
    })
  };

  await lambda.invoke(params).promise();

  return {
    statusCode: 200,
    body: JSON.stringify(`Forwarded event for image ${key} to ImageProcessorFunction`)
  };
};
