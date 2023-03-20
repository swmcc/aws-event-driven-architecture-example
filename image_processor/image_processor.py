import boto3
import json
import os

rekognition = boto3.client('rekognition')
dynamodb = boto3.resource('dynamodb')

def lambda_handler(event, context):
    s3_object = event['Records'][0]['s3']
    bucket = s3_object['bucket']['name']
    key = s3_object['object']['key']

    response = rekognition.detect_labels(
        Image={
            'S3Object': {
                'Bucket': bucket,
                'Name': key
            }
        },
        MaxLabels=10,
        MinConfidence=80
    )

    image_id = os.path.splitext(key)[0]
    labels = [label['Name'] for label in response['Labels']]

    table = dynamodb.Table(os.environ['DYNAMODB_TABLE_NAME'])
    table.put_item(
        Item={
          'ImageId': image_id,
          'Labels': json.dumps(labels)
        }
    )

    return {
      'statusCode': 200,
      'body': json.dumps(f'Processed image {image_id} with labels: {labels}')
    }