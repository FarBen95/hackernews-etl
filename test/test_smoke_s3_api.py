import os
import sys
import json
import uuid

import pytest
from moto import mock_aws


# Make the `extract` directory importable and import the module under test
ROOT = os.path.dirname(os.path.dirname(__file__))
EXTRACT_DIR = os.path.join(ROOT, "extract")
sys.path.insert(0, EXTRACT_DIR)

import s3_api


@mock_aws
def test_s3_api_smoke_with_moto():
    """Smoke test using moto to mock S3.

    - Reads the desired bucket name from terraform outputs if available
    - Creates the bucket in the moto mock
    - Uses `s3_api.load_object_s3` to upload and then verifies with boto3
    """
    import boto3
        
    bucket = "hackernews-etl-dev-raw-data"

    s3 = boto3.client("s3", region_name="us-east-1")
    s3.create_bucket(Bucket=bucket)

    key = f"smoke-test/{uuid.uuid4()}.txt"
    body = "smoke test"

    # upload using the project's s3_api (will call boto3 and be intercepted by moto)
    s3_api.load_object_s3(bucket=bucket, key=key, data=body)

    # verify
    head = s3.head_object(Bucket=bucket, Key=key)
    print(f"Head object metadata: {head}")
    assert head.get("ContentLength") == len(body)

    # cleanup
    s3.delete_object(Bucket=bucket, Key=key)
