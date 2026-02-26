resource "aws_s3_bucket" "bronze_layer" {
  bucket = "${var.project}-${var.environment}-${var.bucket_bronze_layer}"

  tags = {
    Name        = "${var.project}-${var.environment}-${var.bucket_bronze_layer}"
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

resource "aws_s3_bucket" "silver_layer" {
  bucket = "${var.project}-${var.environment}-${var.bucket_silver_layer}"

  tags = {
    Name        = "${var.project}-${var.environment}-${var.bucket_silver_layer}"
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