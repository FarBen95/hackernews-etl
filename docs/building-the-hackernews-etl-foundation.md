# Terraform: Setting Up HackerNews ETL Infrastructure

**Date:** February 9, 2026

---

## Overview

We use Terraform to provision and manage AWS infrastructure for the HackerNews ETL pipeline. Here's how we set up the core services.

## IAM Roles

Create a Terraform role with permissions for the services we need:

```hcl
resource "aws_iam_role" "terraform" {
  name = "hackernews-etl-terraform"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_user.cli.arn
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "terraform" {
  name = "hackernews-etl-terraform-policy"
  role = aws_iam_role.terraform.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ec2:*", "s3:*", "redshift:*", "glue:*", "athena:*", "ssm:*"]
        Resource = "*"
      }
    ]
  })
}
```

## VPC and Networking

Set up VPC with public and private subnets:

```hcl
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
}
```

## S3 Buckets

Create buckets for raw data and Airflow metadata:

```hcl
resource "aws_s3_bucket" "raw" {
  bucket = "hackernews-etl-raw"
}

resource "aws_s3_bucket" "airflow" {
  bucket = "hackernews-etl-airflow"
}

resource "aws_s3_bucket_lifecycle_configuration" "raw" {
  bucket = aws_s3_bucket.raw.id

  rule {
    id     = "archive-old-data"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "GLACIER"
    }
  }
}
```

## Redshift

Provision a minimal Redshift cluster:

```hcl
resource "aws_redshift_cluster" "main" {
  cluster_identifier      = "hackernews-etl"
  database_name           = "analytics"
  master_username         = "admin"
  master_password         = random_password.redshift.result
  node_type               = "dc2.large"
  number_of_nodes         = 2
  publicly_accessible     = false
  skip_final_cluster_snapshot = true
}
```

## Running It

```bash
terraform init
terraform plan
terraform apply
```

All infrastructure is now version-controlled and reproducible in code.
