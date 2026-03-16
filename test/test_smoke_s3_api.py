import os
import sys
import uuid

import boto3
import pytest


# Make the `extract` directory importable and import the module under test
ROOT = os.path.dirname(os.path.dirname(__file__))
EXTRACT_DIR = os.path.join(ROOT, "extract")
sys.path.insert(0, EXTRACT_DIR)

import s3_api


TEST_DIR = os.path.dirname(__file__)
sys.path.insert(0, TEST_DIR)
from aws_test_utils import terraform_outputs, assumed_role_session


def test_s3_api_smoke_with_aws(terraform_outputs, assumed_role_session):
    """Smoke test using real AWS resources.

    - Reads the desired bucket name from terraform outputs
    - Uses `s3_api.load_object_s3` to upload and then verifies with boto3
    """
    bucket = terraform_outputs["s3_bucket_names"]["bronze"]
    s3 = assumed_role_session.client("s3")
    s3.head_bucket(Bucket=bucket)
    key = f"smoke-test/{uuid.uuid4()}.txt"
    body = "smoke test"

    s3_api.load_object_s3(bucket=bucket, key=key, data=body, s3_client=s3)

    try:
        head = s3.head_object(Bucket=bucket, Key=key)
        assert head.get("ContentLength") == len(body)
    finally:
        s3.delete_object(Bucket=bucket, Key=key)