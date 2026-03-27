resource "aws_s3_bucket" "bronze_layer" {
  bucket = "${var.project}-${var.environment}-${var.bucket_bronze_layer}"

  tags = {
    Name        = "${var.project}-${var.environment}-${var.bucket_bronze_layer}"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_s3_bucket_versioning" "bronze_layer" {
  bucket = aws_s3_bucket.bronze_layer.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "silver_layer" {
  bucket = "${var.project}-${var.environment}-${var.bucket_silver_layer}"

  tags = {
    Name        = "${var.project}-${var.environment}-${var.bucket_silver_layer}"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_s3_bucket_versioning" "silver_layer" {
  bucket = aws_s3_bucket.silver_layer.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "gold_layer" {
  bucket = "${var.project}-${var.environment}-${var.bucket_gold_layer}"

  tags = {
    Name        = "${var.project}-${var.environment}-${var.bucket_gold_layer}"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_s3_bucket_versioning" "gold_layer" {
  bucket = aws_s3_bucket.gold_layer.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "config" {
  bucket = "${var.project}-${var.environment}-${var.bucket_config}"

  tags = {
    Name        = "${var.project}-${var.environment}-${var.bucket_config}"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_s3_bucket_versioning" "config" {
  bucket = aws_s3_bucket.config.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "airflow" {
  bucket = "${var.project}-${var.environment}-${var.bucket_airflow}"

  tags = {
    Name        = "${var.project}-${var.environment}-${var.bucket_airflow}"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_s3_bucket_versioning" "airflow" {
  bucket = aws_s3_bucket.airflow.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "glue" {
  bucket = "${var.project}-${var.environment}-${var.bucket_glue}"

  tags = {
    Name        = "${var.project}-${var.environment}-${var.bucket_glue}"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_s3_bucket_versioning" "glue" {
  bucket = aws_s3_bucket.glue.id

  versioning_configuration {
    status = "Enabled"
  }
}

locals {
  backend_files = fileset("${path.module}/../config/backend", "**/*")
  dags_files    = fileset("${path.module}/../dags", "**/*")
}

resource "aws_s3_object" "backend_config" {
  for_each = local.backend_files
  bucket   = aws_s3_bucket.config.bucket
  key      = each.value
  source   = "${path.module}/../config/backend/${each.value}"
  etag     = filemd5("${path.module}/../config/backend/${each.value}")

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_s3_object" "airflow_dags" {
  for_each = local.dags_files
  bucket   = aws_s3_bucket.airflow.bucket
  key      = "dags/${each.value}"
  source   = "${path.module}/../dags/${each.value}"
  etag     = filemd5("${path.module}/../dags/${each.value}")

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_s3_object" "silver_transform_spark_job" {
  bucket = aws_s3_bucket.glue.bucket
  key    = "jobs/silver_transform_spark_job.py"
  source = "${path.module}/../transform/silver_transform_spark_job.py"
  etag   = filemd5("${path.module}/../transform/silver_transform_spark_job.py")

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_s3_object" "gold_transform_spark_job" {
  bucket = aws_s3_bucket.glue.bucket
  key    = "jobs/gold_transform_spark_job.py"
  source = "${path.module}/../transform/gold_transform_spark_job.py"
  etag   = filemd5("${path.module}/../transform/gold_transform_spark_job.py")

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}