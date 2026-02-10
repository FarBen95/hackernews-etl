"""S3 API operations for storing data."""
import logging
from typing import Optional

import boto3
from botocore.exceptions import ClientError

logger = logging.getLogger(__name__)

_S3_CLIENT: Optional[boto3.client] = None


def get_s3_client() -> boto3.client:
    global _S3_CLIENT
    if _S3_CLIENT is None:
        _S3_CLIENT = boto3.client('s3')
        logger.debug("Created new S3 client")
    return _S3_CLIENT


def load_object_s3(bucket: str, key: str, data: str) -> None:
    if not bucket or not key:
        raise ValueError("Bucket and key must not be empty")
    
    try:
        s3 = get_s3_client()
        s3.put_object(
            Bucket=bucket,
            Key=key,
            Body=data
        )
        logger.info(f"Successfully uploaded to s3://{bucket}/{key}")
    except ClientError as e:
        logger.error(f"Failed to upload to S3: {e}")
        raise
    except Exception as e:
        logger.error(f"Unexpected error uploading to S3: {e}")
        raise