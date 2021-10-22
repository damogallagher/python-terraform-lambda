import json
import boto3
import json
# See https://docs.aws.amazon.com/lambda/latest/dg/python-handler.html
def handler(event, context):
    s3 = boto3.resource('s3')
    buckets = [bucket.name for bucket in s3.buckets.all()]
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps({
            "buckets ": buckets
        })
    }