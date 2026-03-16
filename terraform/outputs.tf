output "current_profile" {
  description = "Name of the AWS profile used by Terraform"
  value       = var.profile
}

output "aws_region" {
  description = "AWS region where resources are provisioned"
  value       = var.region
}

output "project" {
  description = "Project name prefix used in resource naming"
  value       = var.project
}

output "environment" {
  description = "Deployment environment name"
  value       = var.environment
}

output "s3_bucket_names" {
  description = "Derived S3 bucket names for pipeline layers and services"
  value = {
    bronze  = aws_s3_bucket.bronze_layer.bucket
    silver  = aws_s3_bucket.silver_layer.bucket
    gold    = aws_s3_bucket.gold_layer.bucket
    docker  = aws_s3_bucket.docker.bucket
    airflow = aws_s3_bucket.airflow.bucket
    glue    = aws_s3_bucket.glue.bucket
  }
}

output "s3_bucket_arns" {
  description = "Derived S3 bucket ARNs for pipeline layers and services"
  value = {
    bronze  = aws_s3_bucket.bronze_layer.arn
    silver  = aws_s3_bucket.silver_layer.arn
    gold    = aws_s3_bucket.gold_layer.arn
    docker  = aws_s3_bucket.docker.arn
    airflow = aws_s3_bucket.airflow.arn
    glue    = aws_s3_bucket.glue.arn
  }
}

# output "ssm_env_parameter_name" {
#   description = "SSM Parameter Store key containing runtime .env values"
#   value       = aws_ssm_parameter.env_param.name
# }

output "vpc_names" {
  description = "Derived VPC and subnet names (IDs not available in root module until resources are wired in)"
  value = {
    vpc            = aws_vpc.vpc.tags.Name
    public_subnet  = aws_subnet.public_subnet.tags.Name
    private_subnet_a = aws_subnet.private_subnet_a.tags.Name
    private_subnet_b = aws_subnet.private_subnet_b.tags.Name
    private_subnet_c = aws_subnet.private_subnet_c.tags.Name
  }
}

output "security_group_names" {
  description = "Derived security group names"
  value = {
    backend_sg          = aws_security_group.backend_sg.name
    redshift_serverless = aws_security_group.redshift_serverless_sg.name
  }
}

output "redshift_names" {
  description = "Derived Redshift Serverless namespace and workgroup names"
  value = {
    namespace = aws_redshiftserverless_namespace.redshift_namespace.namespace_name
    workgroup = aws_redshiftserverless_workgroup.redshift_workgroup.workgroup_name
    # database  = aws_redshiftserverless_database.redshift_database.database_name
  }
}

output "glue_catalog_db_names" {
  description = "Glue Catalog database names for each layer"
  value = {
    bronze = aws_glue_catalog_database.bronze_catalog_db.name
    silver = aws_glue_catalog_database.silver_catalog_db.name
    gold   = aws_glue_catalog_database.gold_catalog_db.name
  }
}

output "glue_crawler_names" {
  description = "Glue crawler names"
  value = {
    bronze = aws_glue_crawler.bronze_crawler.name
  }
}

output "glue_job_names" {
  description = "Glue job names"
  value = {
    silver = aws_glue_job.silver_transform_spark_job.name
    gold   = aws_glue_job.gold_transform_spark_job.name
  }
}

output "iam_role_names" {
  description = "IAM role names used by the pipeline"
  value = {
    glue_crawler = aws_iam_role.glue_crawler_role.name
    glue_job = aws_iam_role.glue_job_role.name
    redshift_serverless = aws_iam_role.redshift_serverless_role.name
  }
}
