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

output "s3_raw_data_bucket_name" {
  description = "Name of the raw data S3 bucket"
  value       = aws_s3_bucket.raw_data.id
}

output "s3_raw_data_bucket_arn" {
  description = "ARN of the raw data S3 bucket"
  value       = aws_s3_bucket.raw_data.arn
}

output "s3_docker_bucket_name" {
  description = "Name of the docker artifacts S3 bucket"
  value       = aws_s3_bucket.docker.id
}

output "s3_docker_bucket_arn" {
  description = "ARN of the docker artifacts S3 bucket"
  value       = aws_s3_bucket.docker.arn
}

output "s3_airflow_bucket_name" {
  description = "Name of the airflow assets S3 bucket"
  value       = aws_s3_bucket.airflow.id
}

output "s3_airflow_bucket_arn" {
  description = "ARN of the airflow assets S3 bucket"
  value       = aws_s3_bucket.airflow.arn
}

output "s3_bucket_names" {
  description = "Convenience map of all S3 bucket names for scripts"
  value = {
    raw_data = aws_s3_bucket.raw_data.id
    docker   = aws_s3_bucket.docker.id
    airflow  = aws_s3_bucket.airflow.id
  }
}

output "ssm_env_parameter_name" {
  description = "SSM Parameter Store key containing runtime .env values"
  value       = aws_ssm_parameter.env_param.name
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.vpc.id
}

output "public_subnet_id" {
  description = "Public subnet ID"
  value       = aws_subnet.public_subnet.id
}

output "private_subnet_id" {
  description = "Private subnet ID"
  value       = aws_subnet.private_subnet.id
}

output "backend_security_group_id" {
  description = "Security group ID for backend/worker compute"
  value       = aws_security_group.backend_sg.id
}

output "backend_instance_id" {
  description = "EC2 instance ID for backend host"
  value       = aws_instance.backend-instance.id
}

output "redshift_namespace_name" {
  description = "Redshift Serverless namespace name"
  value       = aws_redshiftserverless_namespace.redshift_namespace.namespace_name
}

output "redshift_workgroup_name" {
  description = "Redshift Serverless workgroup name"
  value       = aws_redshiftserverless_workgroup.redshift_workgroup.workgroup_name
}
