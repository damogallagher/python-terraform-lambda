import json

def handler(event, context):
    print("Received event: " + json.dumps(event, indent=2))
    print("Here 1")
    return {"statusCode": 200, "body": "Hello World"}