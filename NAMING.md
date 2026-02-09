# AWS & Terraform Naming Conventions

This document defines naming standards for AWS resources and Terraform code in the HackerNews ETL project.

## Project Prefix

All AWS resources must be prefixed with:

```
hackernews-etl
```

Examples:
- `hackernews-etl-raw` (S3 bucket)
- `hackernews-etl-vpc` (VPC)
- `hackernews-etl-redshift` (Redshift cluster)

## AWS Resource Naming

### General Pattern

```
{project-prefix}-{service}-{purpose}-{env}
```

Where `{env}` is optional for shared/default resources.

### S3 Buckets

```
hackernews-etl-{purpose}[-{env}]
```

**Examples:**
- `hackernews-etl-raw` — raw HN data
- `hackernews-etl-processed` — intermediate processed data
- `hackernews-etl-airflow` — Airflow metadata and DAGs
- `hackernews-etl-config` — configuration and reference data
- `hackernews-etl-terraform-state` — Terraform state (optional, can use DynamoDB for lock)

### VPC & Networking

```
hackernews-etl-{resource-type}[-{az}]
```

**Examples:**
- `hackernews-etl-vpc` — VPC
- `hackernews-etl-subnet-public-1a` — public subnet in AZ 1a
- `hackernews-etl-subnet-private-1a` — private subnet in AZ 1a
- `hackernews-etl-sg-ec2` — security group for EC2
- `hackernews-etl-sg-redshift` — security group for Redshift
- `hackernews-etl-nat-gw` — NAT gateway

### Database & Warehouse

```
hackernews-etl-{service}
```

**Examples:**
- `hackernews-etl-redshift` — Redshift cluster
- `hackernews-etl` — Redshift database name (inside cluster)

### Compute

```
hackernews-etl-{service}-{purpose}
```

**Examples:**
- `hackernews-etl-ec2-airflow` — EC2 for Airflow scheduler/worker
- `hackernews-etl-lambda-transform` — Lambda function for transformation

### IAM

```
hackernews-etl-{service}-role
hackernews-etl-{service}-policy
```

**Examples:**
- `hackernews-etl-terraform-role` — Terraform assume role
- `hackernews-etl-ec2-role` — EC2 instance role
- `hackernews-etl-terraform-policy` — Terraform permissions policy

### SSM Parameter Store

```
/hackernews-etl/{environment}/service/{key}
```

**Examples:**
- `/hackernews-etl/prod/db/redshift_password`
- `/hackernews-etl/prod/api/hn_api_key`
- `/hackernews-etl/dev/airflow/fernet_key`

## Terraform Code Naming

### Variables

Use `snake_case` for variable names:

```hcl
variable "aws_region" {
  type = string
}

variable "redshift_node_type" {
  type = string
}

variable "s3_bucket_prefix" {
  type = string
}
```

### Resources

Use `snake_case` for resource logical names:

```hcl
resource "aws_vpc" "main" { ... }

resource "aws_s3_bucket" "raw_data" { ... }

resource "aws_redshift_cluster" "analytics" { ... }

resource "aws_security_group" "ec2" { ... }

resource "aws_iam_role" "terraform" { ... }

resource "aws_dynamodb_table" "terraform_locks" { ... }
```

### Data Sources

Use `snake_case` and prefix with `data_`:

```hcl
data "aws_availability_zones" "available" { ... }

data "aws_ami" "amazon_linux_2" { ... }

data "aws_ssm_parameter" "redshift_password" { ... }
```

### Outputs

Use `snake_case` and be descriptive:

```hcl
output "vpc_id" {
  value = aws_vpc.main.id
}

output "s3_raw_bucket" {
  value = aws_s3_bucket.raw_data.bucket
}

output "redshift_endpoint" {
  value = aws_redshift_cluster.analytics.endpoint
}
```

### Local Values

Use `snake_case` and group related locals:

```hcl
locals {
  project_name = "hackernews-etl"
  environment  = "prod"
  common_tags = {
    Project     = local.project_name
    Environment = local.environment
    ManagedBy   = "Terraform"
  }
}
```

## File Organization

Terraform files follow this structure:

```
terraform/
  main.tf              — provider and terraform configuration
  variables.tf         — variable definitions
  outputs.tf           — output definitions
  vpc.tf               — VPC, subnets, gateways
  security.tf          — security groups
  iam.tf               — IAM roles and policies
  s3.tf                — S3 buckets and configurations
  redshift.tf          — Redshift cluster
  glue.tf              — Glue catalog and jobs
  athena.tf            — Athena workgroups (optional)
  ec2.tf               — EC2 instances
  ssm.tf               — SSM parameters
  terraform.tfvars     — variable values (environment-specific)
```

## Tagging Strategy

All resources should include common tags:

```hcl
tags = {
  Project     = "hackernews-etl"
  Environment = var.environment
  CreatedBy   = "Terraform"
  CreatedDate = timestamp()
}
```
