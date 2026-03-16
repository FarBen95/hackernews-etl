import csv
import io
import os
import time
import uuid

import pytest

from aws_test_utils import terraform_outputs, assumed_role_session


def _wait_for_statement(redshift_data, statement_id, timeout_seconds=300, poll_seconds=5):
    deadline = time.time() + timeout_seconds
    last_status = None
    last_error = None
    while time.time() < deadline:
        details = redshift_data.describe_statement(Id=statement_id)
        last_status = details.get("Status")
        last_error = details.get("Error")
        if last_status == "FINISHED":
            return details
        if last_status in {"FAILED", "ABORTED"}:
            raise AssertionError(
                f"Redshift statement {statement_id} ended in {last_status}: {last_error}"
            )
        time.sleep(poll_seconds)
    raise AssertionError(
        f"Redshift statement {statement_id} did not finish within {timeout_seconds}s (last={last_status})."
    )


def _execute_statement(redshift_data, database, workgroup, sql, secret_arn=None, db_user=None):
    args = {
        "Database": database,
        "WorkgroupName": workgroup,
        "Sql": sql,
    }
    if secret_arn:
        args["SecretArn"] = secret_arn
    if db_user:
        args["DbUser"] = db_user
    return redshift_data.execute_statement(**args)["Id"]


def _render_sample_csv():
    buffer = io.StringIO()
    writer = csv.writer(buffer)
    writer.writerow(["story_id", "title", "score", "by", "created_at"])
    writer.writerow([123456, "Redshift Smoke Test", 42, "smoke-test", "2026-03-11 00:00:00"])
    writer.writerow([123457, "Second Smoke Row", 7, "smoke-test", "2026-03-11 00:05:00"])
    return buffer.getvalue()


def test_redshift_copy_from_gold(terraform_outputs, assumed_role_session):
    """Smoke test for Redshift Serverless: upload gold data and run COPY via Data API."""
    redshift_names = terraform_outputs.get("redshift_names", {})
    s3_bucket_names = terraform_outputs.get("s3_bucket_names", {})
    iam_role_names = terraform_outputs.get("iam_role_names", {})

    workgroup = redshift_names.get("workgroup")
    database = redshift_names.get("database") or os.environ.get("REDSHIFT_DATABASE")
    gold_bucket = s3_bucket_names.get("gold")

    if not workgroup or not gold_bucket:
        pytest.skip("Skipping Redshift test; missing workgroup or gold bucket output.")
    if not database:
        pytest.skip("Skipping Redshift test; set REDSHIFT_DATABASE or add database to outputs.")

    secret_arn = os.environ.get("REDSHIFT_SECRET_ARN")
    db_user = os.environ.get("REDSHIFT_DB_USER")
    if not secret_arn and not db_user:
        pytest.skip("Skipping Redshift test; set REDSHIFT_SECRET_ARN or REDSHIFT_DB_USER.")

    role_arn = os.environ.get("REDSHIFT_COPY_ROLE_ARN")
    role_name = iam_role_names.get("redshift_serverless")
    iam = assumed_role_session.client("iam")
    if not role_arn and role_name:
        role_arn = iam.get_role(RoleName=role_name)["Role"]["Arn"]
    if not role_arn:
        pytest.skip("Skipping Redshift test; set REDSHIFT_COPY_ROLE_ARN or export iam_role_names.redshift_serverless.")

    region = terraform_outputs.get("aws_region") or assumed_role_session.region_name or os.environ.get("AWS_REGION")
    if not region:
        pytest.skip("Skipping Redshift test; unable to resolve AWS region.")

    s3 = assumed_role_session.client("s3")
    redshift_data = assumed_role_session.client("redshift-data")

    table_name = f"smoke_redshift_{uuid.uuid4().hex}"
    prefix = f"smoke-tests/redshift/{table_name}/"
    key = f"{prefix}sample.csv"
    csv_body = _render_sample_csv()

    s3.put_object(Bucket=gold_bucket, Key=key, Body=csv_body)

    create_sql = (
        f"create table if not exists public.{table_name} ("
        "story_id bigint, "
        "title varchar(256), "
        "score int, "
        "by varchar(128), "
        "created_at timestamp);"
    )
    copy_sql = (
        f"COPY public.{table_name} (story_id, title, score, by, created_at) "
        f"FROM 's3://{gold_bucket}/{key}' "
        f"IAM_ROLE '{role_arn}' "
        "FORMAT AS CSV "
        "IGNOREHEADER 1 "
        "TIMEFORMAT 'auto' "
        f"REGION '{region}';"
    )
    count_sql = f"select count(*) as row_count from public.{table_name};"
    drop_sql = f"drop table if exists public.{table_name};"

    try:
        create_id = _execute_statement(
            redshift_data,
            database,
            workgroup,
            create_sql,
            secret_arn=secret_arn,
            db_user=db_user,
        )
        _wait_for_statement(redshift_data, create_id, timeout_seconds=300)

        copy_id = _execute_statement(
            redshift_data,
            database,
            workgroup,
            copy_sql,
            secret_arn=secret_arn,
            db_user=db_user,
        )
        _wait_for_statement(redshift_data, copy_id, timeout_seconds=600)

        count_id = _execute_statement(
            redshift_data,
            database,
            workgroup,
            count_sql,
            secret_arn=secret_arn,
            db_user=db_user,
        )
        _wait_for_statement(redshift_data, count_id, timeout_seconds=120)
        result = redshift_data.get_statement_result(Id=count_id)
        row_count = int(result["Records"][0][0]["longValue"])
        assert row_count >= 2
    finally:
        if secret_arn or db_user:
            try:
                drop_id = _execute_statement(
                    redshift_data,
                    database,
                    workgroup,
                    drop_sql,
                    secret_arn=secret_arn,
                    db_user=db_user,
                )
                _wait_for_statement(redshift_data, drop_id, timeout_seconds=180)
            except Exception as exc:  # pragma: no cover
                print(f"Failed to drop table {table_name}: {exc}")
        s3.delete_object(Bucket=gold_bucket, Key=key)
