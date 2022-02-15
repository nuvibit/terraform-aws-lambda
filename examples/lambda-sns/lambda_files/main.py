import os
import logging
import boto3
logger = logging.getLogger()
logger.setLevel(logging.INFO)

ACCOUNT_ID = os.environ['ACCOUNT_ID']

def lambda_handler(event, context):

    iam_users_current = list()
    iam_client = boto3.client('iam')
    paginator = iam_client.get_paginator(
        'list_users')
    for page in paginator.paginate():
        for user in page['Users']:
            iam_users_current.append(user)

    logger.info(f"AccountId={ACCOUNT_ID}")
    logger.info(f"IAM Users={iam_users_current}")
