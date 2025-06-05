import json
import boto3
import base64
import logging
import urllib.request
import urllib.parse
import urllib.error

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)
handler = logging.StreamHandler()
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)

# Initialize AWS clients
secretsmanager = boto3.client('secretsmanager')


def lambda_handler(event, context):
    """
    AWS Lambda function for rotating Experian passwords.
    This function is triggered by AWS Secrets Manager to rotate the password.

    Args:
        event (dict): Event data from AWS Secrets Manager
        context (object): Lambda context

    Returns:
        dict: Response indicating success or failure
    """
    # Parse event data
    arn = event['SecretId']
    token = event['ClientRequestToken']
    step = event['Step']

    logger.info(f"[step={step}] [arn={arn}] Starting Experian password rotation")

    try:
        # Get the secret value
        secret = get_secret(arn, step)

        # Execute the appropriate step based on the rotation lifecycle
        if step == "createSecret":
            create_secret(secret, arn, token, step)
        elif step == "setSecret":
            set_secret(secret, arn, token, step)
        elif step == "testSecret":
            test_secret(secret, arn, token, step)
        elif step == "finishSecret":
            finish_secret(secret, arn, token, step)
        else:
            raise ValueError(f"Invalid step={step} for secret arn={arn}")

        logger.info(f"[step={step}] [arn={arn}] Successfully completed step")

    except Exception as e:
        logger.error(f"[step={step}] [arn={arn}] Error during step. Error={str(e)}")
        raise

    return {
        'ARN': arn,
        'Token': token,
        'Step': step
    }


def get_secret(arn, step):
    """
    Retrieve the secret from AWS Secrets Manager

    Args:
        arn (str): Secret ARN
        step (str): Rotation step

    Returns:
        dict: Secret data
    """
    try:
        response = secretsmanager.get_secret_value(SecretId=arn)
        if 'SecretString' in response:
            return json.loads(response['SecretString'])
        else:
            return json.loads(base64.b64decode(response['SecretBinary']))
    except Exception as e:
        logger.error(f"[step={step}] [arn={arn}] Error retrieving secret. Error={str(e)}")
        raise


def create_secret(secret, arn, token, step):
    """
    Create a new secret version with a new password

    Args:
        secret (dict): Current secret
        arn (str): Secret ARN
        token (str): Client request token
        step (str): Rotation step
    """
    current_secret = secret.copy()
    new_password = request_new_password(current_secret, arn, step)
    new_secret = current_secret.copy()
    new_secret['password'] = new_password

    secretsmanager.put_secret_value(
        SecretId=arn,
        ClientRequestToken=token,
        SecretString=json.dumps(new_secret),
        VersionStages=['AWSPENDING']
    )

    logger.info(f"[step={step}] [arn={arn}] Created new secret version with AWSPENDING stage")


def set_secret(secret, arn, token, step):
    """
    Set the new password in Experian

    Args:
        secret (dict): Current secret
        arn (str): Secret ARN
        token (str): Client request token
        step (str): Rotation step
    """
    pending_secret = get_pending_secret(arn, token, step)
    reset_password(secret, pending_secret['password'], arn, step)
    logger.info(f"[step={step}] [arn={arn}] Successfully reset password in Experian")


def test_secret(secret, arn, token, step):
    """
    Test the new secret to ensure it works

    Args:
        secret (dict): Current secret
        arn (str): Secret ARN
        token (str): Client request token
        step (str): Rotation step
    """
    pending_secret = get_pending_secret(arn, token, step)
    # Test logic placeholder
    logger.info(f"[step={step}] [arn={arn}] Successfully tested new password")


def finish_secret(secret, arn, token, step):
    """
    Finalize the rotation by marking the new secret as AWSCURRENT

    Args:
        secret (dict): Current secret
        arn (str): Secret ARN
        token (str): Client request token
        step (str): Rotation step
    """
    metadata = secretsmanager.describe_secret(SecretId=arn)
    if not is_secret_ready_to_finalize(metadata, token):
        logger.error(f"[step={step}] [arn={arn}] Secret version is not in AWSPENDING state")
        raise ValueError(f"Secret version is not in AWSPENDING state for secret arn={arn}")

    secretsmanager.update_secret_version_stage(
        SecretId=arn,
        VersionStage='AWSCURRENT',
        MoveToVersionId=token,
        RemoveFromVersionId=get_current_version_id(metadata)
    )

    logger.info(f"[step={step}] [arn={arn}] Successfully finalized secret rotation")

def is_secret_ready_to_finalize(metadata, token):
    """
    Check if the secret is ready to be finalized
    
    Args:
        metadata (dict): Secret metadata
        token (str): Client request token
        
    Returns:
        bool: True if ready to finalize, False otherwise
    """
    for version in metadata.get('VersionIdsToStages', {}).keys():
        if token == version:
            stages = metadata['VersionIdsToStages'][version]
            if 'AWSPENDING' in stages:
                return True
    return False

def get_current_version_id(metadata):
    """
    Get the current version ID of the secret
    
    Args:
        metadata (dict): Secret metadata
        
    Returns:
        str: Current version ID
    """
    for version, stages in metadata.get('VersionIdsToStages', {}).items():
        if 'AWSCURRENT' in stages:
            return version
    return None


def get_pending_secret(arn, token, step):
    """
    Get the pending secret value

    Args:
        arn (str): Secret ARN
        token (str): Client request token
        step (str): Rotation step

    Returns:
        dict: Pending secret data
    """
    try:
        response = secretsmanager.get_secret_value(
            SecretId=arn,
            VersionId=token,
            VersionStage='AWSPENDING'
        )
        if 'SecretString' in response:
            return json.loads(response['SecretString'])
        else:
            return json.loads(base64.b64decode(response['SecretBinary']))
    except Exception as e:
        logger.error(f"[step={step}] [arn={arn}] Error retrieving pending secret. Error={str(e)}")
        raise


def request_new_password(secret, arn, step):
    """
    Call Experian API to request a new password

    Args:
        secret (dict): Current secret
        arn (str): Secret ARN
        step (str): Rotation step

    Returns:
        str: New password
    """
    endpoint = secret.get('endpoint', 'https://ss3.experian.com/securecontrol/reset/passwordreset')
    auth_string = f"{secret['username']}:{secret['password']}"
    base64_bytes = base64.b64encode(auth_string.encode('utf-8'))
    base64_auth = base64_bytes.decode('utf-8')  

    headers = {
        'Authorization': f'Basic {base64_auth}',
        'Content-Type': 'application/x-www-form-urlencoded'
    }

    data = {
        'command': 'requestnewpassword',
        'application': secret.get('application', 'netconnect')
    }

    data_encoded = urllib.parse.urlencode(data).encode('ascii')
    req = urllib.request.Request(endpoint, data=data_encoded, headers=headers, method='POST')

    try:
        with urllib.request.urlopen(req) as response:
            response_data = response.read().decode('utf-8')
            if 'password' in response_data.lower():
                new_password = response_data.strip()
                logger.info(f"[step={step}] [arn={arn}] Successfully requested new password from Experian")
                return new_password
            else:
                raise ValueError(f"Failed to extract password from response. data={response_data}")
    except urllib.error.HTTPError as e:
        logger.error(f"[step={step}] [arn={arn}] HTTP error during password request. code={e.code} reason={e.reason}")
        raise
    except urllib.error.URLError as e:
        logger.error(f"[step={step}] [arn={arn}] URL error during password request. reason={e.reason}")
        raise
    except Exception as e:
        logger.error(f"[step={step}] [arn={arn}] Error requesting new password. Error={str(e)}")
        raise


def reset_password(secret, new_password, arn, step):
    """
    Call Experian API to reset the password

    Args:
        secret (dict): Current secret
        new_password (str): New password to set
        arn (str): Secret ARN
        step (str): Rotation step
    """
    endpoint = secret.get('endpoint', 'https://ss3.experian.com/securecontrol/reset/passwordreset')
    auth_string = f"{secret['username']}:{secret['password']}"
    base64_bytes = base64.b64encode(auth_string.encode('utf-8'))
    base64_auth = base64_bytes.decode('utf-8')  

    headers = {
        'Authorization': f'Basic {base64_auth}',
        'Content-Type': 'application/x-www-form-urlencoded'
    }

    data = {
        'command': 'resetpassword',
        'newpassword': new_password,
        'application': secret.get('application', 'netconnect')
    }

    data_encoded = urllib.parse.urlencode(data).encode('ascii')
    req = urllib.request.Request(endpoint, data=data_encoded, headers=headers, method='POST')

    try:
        with urllib.request.urlopen(req) as response:
            response_data = response.read().decode('utf-8')
            if response.status == 200:
                logger.info(f"[step={step}] [arn={arn}] Successfully reset password in Experian for secret name={secret['name']}")
            else:
                raise ValueError(f"Failed to reset password. data={response_data}")
    except urllib.error.HTTPError as e:
        logger.error(f"[step={step}] [arn={arn}] HTTP error during password reset. code={e.code} reason={e.reason}")
        raise
    except urllib.error.URLError as e:
        logger.error(f"[step={step}] [arn={arn}] URL error during password reset. reason={e.reason}")
        raise
    except Exception as e:
        logger.error(f"[step={step}] [arn={arn}] Error resetting password. Error={str(e)}")
        raise