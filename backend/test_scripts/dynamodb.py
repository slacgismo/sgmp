import boto3
from datetime import datetime, timedelta
from boto3.dynamodb.conditions import Key

if __name__ == '__main__':
    device_id = 47571
    dynamodb = boto3.resource('dynamodb', region_name='us-west-1')
    table = dynamodb.Table('GismoLab_iot')
    response = table.query(
        ScanIndexForward=False,
        KeyConditionExpression=
            Key('device_id').eq(device_id)
    )
    print(len(response['Items']))
    i = 0
    for item in response['Items']:
        i += 1
        if i == 100: break
        ms = item['timestamp']
        ts = datetime.utcfromtimestamp(ms // 1000).replace(microsecond=ms % 1000 * 1000)
        print(ts.strftime('%Y-%m-%d %H:%M:%S'), item['device_data']['ts'])