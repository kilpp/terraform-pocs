import boto3
import json
import os
import secrets
import string


def generate_random_password(length=16):
    # Define the characters to use for password generation
    alphabet = string.ascii_letters + string.digits + string.punctuation
    # Generate a random password
    password = ''.join(secrets.choice(alphabet) for i in range(length))
    return password


def lambda_handler(event, context):
    # Retrieve the secret details
    secretsmanager_client = boto3.client('secretsmanager')
    secret_arn = os.environ['SECRET_ARN']
    print(f"EVENT={event}")

    # Get the current secret value
    current_secret_value = secretsmanager_client.get_secret_value(
        SecretId=secret_arn
    )

    # Generate a new random password
    new_password = generate_random_password()

    # Update the secret with the new password
    secretsmanager_client.put_secret_value(
        SecretId=secret_arn,
        SecretString=json.dumps({
            "username": json.loads(current_secret_value['SecretString'])['username'],
            "password": new_password
        })
    )

    return {
        'statusCode': 200,
        'body': json.dumps('Secret rotated successfully')
    }