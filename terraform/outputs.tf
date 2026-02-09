output  "current_profile" {
  description = "Name of the profile used"
  value = var.profile
}

output "s3_raw_data_bucket_name" {
  description = "Name of the raw data S3 bucket"
  value       = aws_s3_bucket.raw_data.id
}

output "s3_raw_data_bucket_arn" {
  description = "ARN of the raw data S3 bucket"
  value       = aws_s3_bucket.raw_data.arn
}

# output "redshift_cluster_id" {
#   description = "Redshift cluster identifier"
#   value       = aws_redshift_cluster.main.id
# }

# output "redshift_cluster_endpoint" {
#   description = "Redshift cluster endpoint"
#   value       = aws_redshift_cluster.main.endpoint
# }

# output "redshift_cluster_database_name" {
#   description = "Redshift database name"
#   value       = aws_redshift_cluster.main.database_name
# }

# output "redshift_iam_role_arn" {
#   description = "IAM role ARN for Redshift"
#   value       = aws_iam_role.redshift.arn
# }

# output "vpc_id" {
#   description = "VPC ID"
#   value       = aws_vpc.main.id
# }

# output "private_subnet_ids" {
#   description = "Private subnet IDs"
#   value       = aws_subnet.private[*].id
# }

# output "public_subnet_ids" {
#   description = "Public subnet IDs"
#   value       = aws_subnet.public[*].id
# }
