resource "aws_glue_catalog_database" "bronze_catalog_db" {
  name        = var.bronze_db_name
  description = "Glue Catalog Database for S3 bronze layer"
}

resource "aws_glue_catalog_database" "silver_catalog_db" {
  name        = var.silver_db_name
  description = "Glue Catalog Database for S3 silver layer"
}

resource "aws_glue_catalog_database" "gold_catalog_db" {
  name        = var.gold_db_name
  description = "Glue Catalog Database for S3 gold layer"
}

resource "aws_glue_crawler" "bronze_crawler" {
  name          = "${var.bronze_db_name}-crawler"
  database_name = aws_glue_catalog_database.bronze_catalog_db.name
  role          = aws_iam_role.glue_crawler_role.arn

  s3_target {
    path = "s3://${aws_s3_bucket.bronze_layer.bucket}"
  }

  schema_change_policy {
    update_behavior = "LOG"
    delete_behavior = "LOG"
  }

  recrawl_policy {
    recrawl_behavior = "CRAWL_NEW_FOLDERS_ONLY"
  }
}

resource "aws_glue_job" "silver_transform_spark_job" {
  name     = "silver-transform-spark-job"
  role_arn = aws_iam_role.glue_job_role.arn

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_object.silver_transform_spark_job.bucket}/${aws_s3_object.silver_transform_spark_job.key}"
    python_version  = "3"
  }

  glue_version      = "5.0"
  worker_type       = "G.1X" # 4 vCPU, 16 GB RAM per worker
  number_of_workers = 10
  timeout           = 60 # minutes
  max_retries       = 1

  default_arguments = {
    "--enable-metrics"                   = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-spark-ui"                  = "true"
    "--spark-event-logs-path"            = "s3://${aws_s3_bucket.glue.bucket}/spark-logs/"
    "--job-language"                     = "python"
    "--TempDir"                          = "s3://${aws_s3_bucket.glue.bucket}/temp/"
    "--source_database"                  = aws_glue_catalog_database.bronze_catalog_db.name
    "--source_table"                     = "items"
    "--output_database"                  = aws_glue_catalog_database.silver_catalog_db.name
    "--output_path"                      = "s3://${aws_s3_bucket.silver_layer.bucket}/"
  }

  execution_property {
    max_concurrent_runs = 1
  }

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_glue_job" "gold_transform_spark_job" {
  name     = "gold-transform-spark-job"
  role_arn = aws_iam_role.glue_job_role.arn

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_object.gold_transform_spark_job.bucket}/${aws_s3_object.gold_transform_spark_job.key}"
    python_version  = "3"
  }

  glue_version      = "5.0"
  worker_type       = "G.1X" # 4 vCPU, 16 GB RAM per worker
  number_of_workers = 10
  timeout           = 60 # minutes
  max_retries       = 1

  default_arguments = {
    "--enable-metrics"                   = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-spark-ui"                  = "true"
    "--spark-event-logs-path"            = "s3://${aws_s3_bucket.glue.bucket}/spark-logs/"
    "--job-language"                     = "python"
    "--TempDir"                          = "s3://${aws_s3_bucket.glue.bucket}/temp/"
    "--source_database"                  = aws_glue_catalog_database.silver_catalog_db.name
    "--source_tables" = {
      stories  = "stories",
      comments = "comments",
      jobs     = "jobs",
      polls    = "polls",
      pollopt  = "pollopt",
      asks     = "asks"
    }
    "--output_database"                  = aws_glue_catalog_database.gold_catalog_db.name
    "--output_path" = "s3://${aws_s3_bucket.gold_layer.bucket}/"
  }

  execution_property {
    max_concurrent_runs = 1
  }

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}
