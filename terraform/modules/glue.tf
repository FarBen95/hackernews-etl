resource "aws_glue_catalog_database" "glue_catalog_db" {
  name = var.glue_db_name
  description = "Glue Catalog Database for ${var.glue_db_name}"
}

resource "aws_glue_crawler" "glue_crawler" {
  name = "${var.glue_db_name}-crawler"
  database_name = aws_glue_catalog_database.glue_catalog_db.name
  role = aws_iam_role.glue_crawler_role.arn
  
  s3_target {
    path = "s3://${aws_s3_bucket.raw_data.bucket}"
  }
}

