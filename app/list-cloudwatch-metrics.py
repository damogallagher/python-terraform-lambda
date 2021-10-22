import json
import boto3
import json
# See https://docs.aws.amazon.com/lambda/latest/dg/python-handler.html
def handler(event, context):
    client = boto3.client('cloudwatch')
    response = client.list_metrics(
        Namespace='AmazonMWAA',
        MetricName='SchedulerHeartbeat',
        Dimensions = [
          {
            "Name": "Function",
            "Value": "Scheduler"
          },
          {
            "Name": "Environment",
            "Value": "csx-nonprod-dataops"
          }
        ]    
    )
    print(response)
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps({
            "response ": response
        })
    }