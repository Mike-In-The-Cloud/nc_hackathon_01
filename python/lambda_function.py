import boto3
import urllib
import json
from botocore.exceptions import ClientError
from datetime import datetime

'''
function to get time of execution of the script
'''
def execution_time():
    # datetime object containing current date and time
    now = datetime.now()
    # dd/mm/YY H:M:S
    dt_string = now.strftime("%d/%m/%Y %H:%M:%S")
    return dt_string


'''
Inputs
A - 
B - 
C - 

Output
return_list - json object 
'''
def kindergarten(a, b, c):
        namelist = ["Alice", "Bob","Charlie","Eve","Fred","Ginny","Harriet","Ileana","Joseph","Kincaid","Larry"]
        mydict = {}
        seeds = {
            "G":"Grass",
            "C":"Clover",
            "R":"Radishes",
            "V":"Voilets"
            }
        for i in range(len(sorted(namelist))):
            mydict[namelist[i]] = a[0],a[1],b[0],b[1]
            a = a[2:]
            b = b[2:]

        values = list(mydict[c])
        listtems = []
        for items in range(len(values)):
            listtems.append(seeds[values[items]])
            
        return_list = (",".join(listtems))
        #print(return_list)
        return return_list

'''
Inputs
bucket - bucket name
key - file name
json_object - return value from kindergarten

function to put json object into S3 bucket for persistant storage 
of the return values processed.
'''
def put_object_bucket(bucket,key,json_object,s3):
    
    
    # try catch to put json in s3 bucket
    # using upload_fileobj method as it does not need the file to be on disk
    try:
        
        s3object = s3.Object(bucket, key)
        s3object.put(Body=(bytes(json.dumps(json_object).encode('UTF-8'))))
        return True

    except ClientError as e:
        print(e.response['Error'])
    return True

def load_data_from_s3(S3_OBJ,BUCKET,KEY):
    try:
        s3_obj,bucket,key = S3_OBJ,BUCKET,KEY
        # get s3 object
        s3_json_obj = s3_obj.Object(bucket,key)
        # read s3 object - is a string
        data = s3_json_obj.get()['Body'].read().decode('utf-8')
        list_data = json.loads(data)
        return list_data
    except ClientError as e:
        print(e.response['Error'])


'''
main function
Input - event json object
'''
def lambda_handler(event, context):
    record_time = execution_time()

    # source https://docs.aws.amazon.com/AmazonS3/latest/userguide/notification-content-structure.html
    # and https://stackoverflow.com/questions/62426862/how-to-get-s3-trigger-details-inside-lambda-function
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')
    s3 = boto3.resource('s3')
    json_data = load_data_from_s3(s3,bucket,key)
    

    # get events 
    a = json_data["A"]
    b = json_data["B"]
    c = json_data["C"]
    return_value = kindergarten(a, b, c)
    
    # save to s3
    key = "outputs/output_{}.json".format(record_time)
    put_object_bucket(bucket, key, return_value,s3)
    
    
    return {
        'statusCode': 200,
        'body': json.dumps(return_value)
    }
    