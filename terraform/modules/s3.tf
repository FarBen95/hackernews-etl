resource "aws_s3_bucket" "raw_data" {
  bucket = "${var.project}-${var.environment}-${var.bucket_raw_data}"

  tags = {
    Name        = "${var.project}-${var.environment}-${var.bucket_raw_data}"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_s3_bucket_versioning" "raw_data" {
  bucket = aws_s3_bucket.raw_data.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "docker" {
  bucket = "${var.project}-${var.environment}-${var.bucket_docker}"

  tags = {
    Name        = "${var.project}-${var.environment}-${var.bucket_docker}"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_s3_bucket_versioning" "docker" {
  bucket = aws_s3_bucket.docker.id

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