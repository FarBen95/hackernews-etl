import json
import os
from os import path
import uuid
from typing import Any, Dict, Optional, Tuple

import boto3
import pytest
from botocore.exceptions import ClientError, EndpointConnectionError, MissingDependencyException, NoCredentialsError, ProfileNotFound


ROOT = os.path.dirname(os.path.dirname(__file__))
DEFAULT_OUTPUTS_PATH = os.path.join(ROOT, "terraform", "outputs.json")


@pytest.fixture(scope="session")
def terraform_outputs(path: str = DEFAULT_OUTPUTS_PATH) -> Dict[str, Any]:
    try:
        with open(path, "r") as handle:
            raw = json.load(handle)
        return {key: value.get("value") for key, value in raw.items()}
    except FileNotFoundError:
        pytest.skip("Skipping AWS tests; terraform/outputs.json not found.")


@pytest.fixture(scope="session")
def assumed_role_session(pytestconfig):
    profile = pytestconfig.getini("profile")
    region = pytestconfig.getini("aws_region")
    role_arn = pytestconfig.getini("test_role_arn")
    session_name = pytestconfig.getini("session")
    try:
        base_session = boto3.Session(profile_name=profile)
        sts = base_session.client("sts")
        response = sts.assume_role(
            RoleArn=role_arn,
            RoleSessionName=f"{session_name}-{uuid.uuid4()}",
        )
        creds = response["Credentials"]
        return boto3.Session(
            aws_access_key_id=creds["AccessKeyId"],
            aws_secret_access_key=creds["SecretAccessKey"],
            aws_session_token=creds["SessionToken"],
            region_name=region,
        )
    except NoCredentialsError as exc:
        pytest.skip(
            f"Skipping AWS tests; unable to create base session or unable to assume role: {exc}")
