import json
import boto3

def handler(event, context):
    print("Received event: " + json.dumps(event, indent=2))
    print("Here 1")
    s3 = boto3.resource('s3')
    buckets = [bucket.name for bucket in s3.buckets.all()]
    print(buckets)
    return {"statusCode": 200, "body": "Hello World"}