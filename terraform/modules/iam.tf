resource "aws_iam_role" "glue_crawler_role" {
  name = "${var.project}-glue-crawler-role"
  assume_role_policy = data.aws_iam_policy_document.glue_crawler_assume_role_policy.json
}

data "aws_iam_policy_document" "glue_crawler_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "glue_crawler_policy" {
    statement {
        actions = [
            "s3:GetObject",
            "s3:PutObject"
        ]
        resources = [
            "arn:aws:s3:::${aws_s3_bucket.raw_data.bucket}/*"
        ]
    }
}

resource "aws_iam_role_policy" "glue_crawler_inline_policy" {
    name   = "${var.project}-glue-crawler-policy"
    role   = aws_iam_role.glue_crawler_role.id
    policy = data.aws_iam_policy_document.glue_crawler_policy.json
}