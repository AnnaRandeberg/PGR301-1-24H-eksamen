import base64
import boto3
import json
import random
import os

# Set up the AWS clients

bedrock_client = boto3.client("bedrock-runtime", region_name="us-east-1")
s3_client = boto3.client("s3")

    # Define the model ID and S3 bucket name (replace with your actual bucket name)
model_id = "amazon.titan-image-generator-v1"

def lambda_handler(event, context):
    try: 
        bucket_name = os.environ.get("BUCKET_NAME", "pgr301-couch-explorers")
        candidate_number = os.environ.get("CANDIDATE_NR", "41")
        
        body = json.loads(event.get("body", "{}"))
    
    # Frank; Important; Change this prompt to something else before the presentation with the investors!
        prompt = body.get("prompt", "cool image")
    
        
        seed = random.randint(0, 2147483647)
     
        s3_image_path = f"{candidate_number}/generated_images/titan_{seed}.png"

        native_request = {
            "taskType": "TEXT_IMAGE",
            "textToImageParams": {"text": prompt},
            "imageGenerationConfig": {
                "numberOfImages": 1,
                "quality": "standard",
                "cfgScale": 8.0,
                "height": 1024,
                "width": 1024,
                "seed": seed,
    }
}

        response = bedrock_client.invoke_model(modelId=model_id, body=json.dumps(native_request))
        model_response = json.loads(response["body"].read())
        
    # Extract and decode the Base64 image data
        base64_image_data = model_response["images"][0]
        image_data = base64.b64decode(base64_image_data)

  
    # Upload the decoded image data to S3
        s3_client.put_object(Bucket=bucket_name, Key=s3_image_path, Body=image_data)

        image_url = f"https://{bucket_name}.s3.amazonaws.com/{s3_image_path}"
        return {
            "statusCode": 200,
            "body": json.dumps({
                "message": "Ferdig! du har nå et generert bilde, gratulerer!!", 
                
            })
            
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({
                "message": "oii det funket ikke, skjedde en feil:(((",
                
            })
    }