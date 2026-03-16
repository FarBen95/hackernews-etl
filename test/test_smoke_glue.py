import json
import os
import sys
import time
import uuid

TEST_DIR = os.path.dirname(__file__)
sys.path.insert(0, TEST_DIR)
from aws_test_utils import terraform_outputs, assumed_role_session


def _wait_for_crawler_state(glue, crawler_name, desired_state, timeout_seconds=900, poll_seconds=10):
    deadline = time.time() + timeout_seconds
    last_state = None
    while time.time() < deadline:
        crawler = glue.get_crawler(Name=crawler_name)["Crawler"]
        last_state = crawler.get("State")
        print(last_state)
        if last_state == desired_state:
            return crawler
        time.sleep(poll_seconds)
    raise AssertionError(
        f"Crawler {crawler_name} did not reach state {desired_state} within {timeout_seconds}s (last={last_state})."
    )


def _wait_for_table(glue, database_name, table_name, timeout_seconds=300, poll_seconds=10):
    deadline = time.time() + timeout_seconds
    last_error = None
    while time.time() < deadline:
        try:
            return glue.get_table(DatabaseName=database_name, Name=table_name)["Table"]
        except glue.exceptions.EntityNotFoundException as exc:
            last_error = exc
            print(last_error)
            time.sleep(poll_seconds)
    raise AssertionError(
        f"Table {table_name} not found in database {database_name} after {timeout_seconds}s."
    ) from last_error


def _wait_for_job_run(glue, job_name, run_id, desired_state="SUCCEEDED", timeout_seconds=1800, poll_seconds=15):
    deadline = time.time() + timeout_seconds
    last_state = None
    last_error = None
    while time.time() < deadline:
        job_run = glue.get_job_run(JobName=job_name, RunId=run_id, PredecessorsIncluded=False)["JobRun"]
        last_state = job_run.get("JobRunState")
        last_error = job_run.get("ErrorMessage")
        print(last_state)
        if last_state == desired_state:
            return job_run
        if last_state in {"FAILED", "TIMEOUT", "STOPPED"}:
            raise AssertionError(
                f"Glue job {job_name} run {run_id} ended in state {last_state}: {last_error}"
            )
        time.sleep(poll_seconds)
    raise AssertionError(
        f"Glue job {job_name} run {run_id} did not reach {desired_state} within {timeout_seconds}s (last={last_state})."
    )


def test_glue_bronze_crawler_creates_catalog(terraform_outputs, assumed_role_session):
    """Smoke test for Glue bronze crawler: upload data, run crawler, verify catalog table."""
    glue = assumed_role_session.client("glue")
    s3 = assumed_role_session.client("s3")

    bronze_db = terraform_outputs["glue_catalog_db_names"]["bronze"]
    crawler_name = terraform_outputs["glue_crawler_names"]["bronze"]
    bronze_bucket = terraform_outputs["s3_bucket_names"]["bronze"]

    glue.get_database(Name=bronze_db)
    glue.get_crawler(Name=crawler_name)

    table_name = f"smoke_test_{uuid.uuid4().hex}"
    prefix = f"{table_name}/"
    key = f"{prefix}sample.json"
    sample_body = json.dumps({
        "event_id": 1,
        "event_type": "smoke",
        "event_timestamp": "2026-03-11T00:00:00Z",
    })

    # Ensure we pick a table name that doesn't already exist.
    while True:
        try:
            glue.get_table(DatabaseName=bronze_db, Name=table_name)
        except glue.exceptions.EntityNotFoundException:
            break
        table_name = f"smoke_test_{uuid.uuid4().hex}"
        prefix = f"{table_name}/"
        key = f"{prefix}sample.json"

    s3.put_object(Bucket=bronze_bucket, Key=key, Body=sample_body)

    try:
        _wait_for_crawler_state(glue, crawler_name, "READY", timeout_seconds=600)
        try:
            glue.start_crawler(Name=crawler_name)
        except glue.exceptions.CrawlerRunningException:
            _wait_for_crawler_state(glue, crawler_name, "READY", timeout_seconds=200)
            glue.start_crawler(Name=crawler_name)

        crawler = _wait_for_crawler_state(glue, crawler_name, "READY", timeout_seconds=200)
        last_crawl = crawler.get("LastCrawl") or {}
        assert last_crawl.get("Status") == "SUCCEEDED"

        table = _wait_for_table(glue, bronze_db, bronze_bucket, timeout_seconds=150)
        location = table.get("StorageDescriptor", {}).get("Location", "")
        assert location.startswith(f"s3://{bronze_bucket}/{prefix}")
    finally:
        s3.delete_object(Bucket=bronze_bucket, Key=key)
        try:
            glue.delete_table(DatabaseName=bronze_db, Name=table_name)
        except glue.exceptions.EntityNotFoundException:
            pass


def test_glue_silver_job_transforms(terraform_outputs, assumed_role_session):
    """Smoke test for Glue silver job: upload sample JSON, run job, verify silver output."""
    glue = assumed_role_session.client("glue")
    s3 = assumed_role_session.client("s3")

    bronze_db = terraform_outputs["glue_catalog_db_names"]["bronze"]
    bronze_bucket = terraform_outputs["s3_bucket_names"]["bronze"]
    silver_bucket = terraform_outputs["s3_bucket_names"]["silver"]
    silver_job_name = terraform_outputs["glue_job_names"]["silver"]

    table_name = f"events_bronze_smoke_{uuid.uuid4().hex}"
    input_prefix = f"{table_name}/"
    input_key = f"{input_prefix}sample.json"
    output_prefix = f"smoke-tests/{table_name}/"
    output_path = f"s3://{silver_bucket}/{output_prefix}"

    sample_body = json.dumps({
        "id": 987654321,
        "type": "story",
        "time": "2026-03-11 00:00:00",
        "by": "smoke-test",
        "title": "Glue Silver Smoke Test",
        "score": 42,
        "descendants": 3,
        "url": "https://example.com/glue-smoke",
        "deleted": False,
        "dead": False,
        "ingestion_time": "2026-03-12 12:34:56",
    })

    s3.put_object(Bucket=bronze_bucket, Key=input_key, Body=sample_body)

    job_run_id = None
    try:
        glue.create_table(
            DatabaseName=bronze_db,
            TableInput={
                "Name": table_name,
                "TableType": "EXTERNAL_TABLE",
                "Parameters": {
                    "classification": "json",
                },
                "StorageDescriptor": {
                    "Location": f"s3://{bronze_bucket}/{input_prefix}",
                    "InputFormat": "org.apache.hadoop.mapred.TextInputFormat",
                    "OutputFormat": "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat",
                    "SerdeInfo": {
                        "SerializationLibrary": "org.openx.data.jsonserde.JsonSerDe",
                        "Parameters": {
                            "ignore.malformed.json": "true",
                        },
                    },
                    "Columns": [
                        {"Name": "id", "Type": "bigint"},
                        {"Name": "type", "Type": "string"},
                        {"Name": "time", "Type": "string"},
                        {"Name": "by", "Type": "string"},
                        {"Name": "title", "Type": "string"},
                        {"Name": "score", "Type": "int"},
                        {"Name": "descendants", "Type": "int"},
                        {"Name": "url", "Type": "string"},
                        {"Name": "deleted", "Type": "boolean"},
                        {"Name": "dead", "Type": "boolean"},
                        {"Name": "ingestion_time", "Type": "string"},
                    ],
                },
            },
        )

        job_run = glue.start_job_run(
            JobName=silver_job_name,
            Arguments={
                "--source_database": bronze_db,
                "--source_table": table_name,
                "--output_path": output_path,
            },
        )
        job_run_id = job_run["JobRunId"]
        _wait_for_job_run(glue, silver_job_name, job_run_id, timeout_seconds=1800)

        output_objects = s3.list_objects_v2(Bucket=silver_bucket, Prefix=output_prefix).get("Contents", [])
        output_keys = [obj["Key"] for obj in output_objects]
        assert any(key.endswith(".parquet") for key in output_keys)
    finally:
        # s3.delete_object(Bucket=bronze_bucket, Key=input_key)

        output_objects = s3.list_objects_v2(Bucket=silver_bucket, Prefix=output_prefix).get("Contents", [])
        # if output_objects:
        #     s3.delete_objects(
        #         Bucket=silver_bucket,
        #         Delete={"Objects": [{"Key": obj["Key"]} for obj in output_objects]},
        #     )

        try:
            print("delete")
            # glue.delete_table(DatabaseName=bronze_db, Name=table_name)
        except glue.exceptions.EntityNotFoundException:
            pass

        try:
            table = glue.get_table(DatabaseName="default", Name="events_silver")["Table"]
            location = table.get("StorageDescriptor", {}).get("Location", "")
            # if location.startswith(output_path):
            #     glue.delete_table(DatabaseName="default", Name="events_silver")
        except glue.exceptions.EntityNotFoundException:
            pass
