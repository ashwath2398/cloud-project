import json #binaires to JSON
import boto3 #boto allows python to touch aws services

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('cloud-portfolio') #telling to find table named cloud portfolio

def lambda_handler(event, context): #API gateway looks for this 
        #Prepare CORS headers (Required for your website to talk to AWS)
    headers = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
    }

    try:
        
        response = table.get_item(Key={'id': 'count'})
        
        #check if table empty or not
        if 'Item' in response:
            views = response['Item']['views']
        else:
            views = 0

        #force dynamodb to store int insteda of decimal
        views = int(views) + 1
        
        
        table.put_item(Item={'id': 'count', 'views': views})
        
        
        return {
            'statusCode': 200, #internet code of success
            'headers': headers,
            'body': json.dumps(views) 
        }

    except Exception as e:
        print(f"Error: {e}")
        return {
            'statusCode': 500,
            'headers': headers,
            'body': json.dumps("Error updating count")
        }