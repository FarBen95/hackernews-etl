variable "region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "hackernews-etl"
}

variable "profile" {
  description = "AWS CLI Profile"
  type = string
  default = "default"
}

variable "role_arn" {
  description = "Role ARN for provider authentication"
  type = string
}

variable "session_name" {
  description = "Role session name"
  type = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "VPC public subnet CIDR block"
  default = "10.0.10.0/24"
}

variable "private_subnet_cidr" {
  description = "VPC private subnet CIDR block"
  default = "10.0.20.0/24"
}

variable "instance_type" {
  description = "Instance type for EC2"
  default = "t3.micro"
}

variable "ami_id" {
  description = "Id of Amazon Linux 2023"
  default = "ami-0532be01f26a3de55"
}

variable "s3_prefix" {
  description = "Prefix of S3 buckets ARN"
  default = ""
}

variable "bucket_bronze_layer" {
  description = "Name of S3 bronze layer bucket"
  default = "bronze-layer"
}

variable "bucket_silver_layer" {
  description = "Name of S3 silver layer bucket"
  default = "silver-layer"
}

variable "bucket_gold_layer" {
  description = "Name of S3 gold data bucket"
  default = "gold-data"
}

variable "bucket_docker" {
  description = "Name of S3 docker bucket"
  default = "docker"
}

variable "bucket_airflow" {
  description = "Name of S3 airflow bucket"
  default = "airflow"
}

variable "param_env" {
  description = "SSM parameter name of .env file"
  default = ".env"
}

variable "redshift_database_name" {
  description = "Redshift database name"
  type        = string
  default     = "hackernews_db"
}

variable "redshift_db_username" {
  description = "Redshift database username"
  type        = string
  default     = "admin"
}

variable "redshift_db_password" {
  description = "Redshift database password"
  type        = string
  sensitive   = true
}

variable "redshift_base_capacity" {
  description = "Number of Redshift RPU capacity"
  type        = number
  default     = 4
}

variable "glue_db_name" {
  description = "Glue Catalog Database name"
  type        = string
  default     = "hackernews_db"
}

