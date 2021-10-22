import json
import boto3
import json
from datetime import date, timedelta, datetime

# See https://docs.aws.amazon.com/lambda/latest/dg/python-handler.html
def handler(event, context):
    days = 0
    yesterday=date.today() - timedelta(days=days)
    tomorrow=date.today() + timedelta(days=1)

    client = boto3.client('cloudwatch')
    response = client.get_metric_data(
        MetricDataQueries=[
            {
                'Id': 'getMetricData',
                'MetricStat': {
                    'Metric': {
                        'Namespace': 'AmazonMWAA',
                        'MetricName': 'SchedulerHeartbeat',
                        'Dimensions': [
                            {
                              "Name": "Function",
                              "Value": "Scheduler"
                            },
                            {
                              "Name": "Environment",
                              "Value": "csx-nonprod-dataops"
                            },
                        ]
                    },
                    'Period': 60 * 60,
                    'Stat': 'Sum',
                  },
                'Label': 'human-label',
                'ReturnData': True,
            },
        ],
        StartTime=datetime(yesterday.year, yesterday.month, yesterday.day), 
        EndTime=datetime(tomorrow.year, tomorrow.month, tomorrow.day),
        ScanBy='TimestampDescending',
    )
    print(response)
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps({
            "response ": response
        }, indent=4, sort_keys=True, default=str)
    }