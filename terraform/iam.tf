data "aws_caller_identity" "current" {}

# IAM Role for Glue Crawler
resource "aws_iam_role" "glue_crawler_role" {
  name               = "${var.project}-glue-crawler-role"
  assume_role_policy = data.aws_iam_policy_document.glue_crawler_trust_policy.json
}

data "aws_iam_policy_document" "glue_crawler_trust_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

data "aws_iam_policy_document" "glue_crawler_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.bronze_layer.bucket}/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_iam_role_policy" "glue_crawler_inline_policy" {
  name   = "${var.project}-glue-crawler-policy"
  role   = aws_iam_role.glue_crawler_role.id
  policy = data.aws_iam_policy_document.glue_crawler_policy.json
}

resource "aws_iam_role_policy_attachment" "glue_crawler_managed_policy_attachment" {
  role       = aws_iam_role.glue_crawler_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# IAM Role for Glue Job
resource "aws_iam_role" "glue_job_role" {
  name               = "${var.project}-glue-job-role"
  assume_role_policy = data.aws_iam_policy_document.glue_job_trust_policy.json
}

data "aws_iam_policy_document" "glue_job_trust_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

data "aws_iam_policy_document" "glue_job_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.bronze_layer.bucket}/*",
      "arn:aws:s3:::${aws_s3_bucket.silver_layer.bucket}/*",
      "arn:aws:s3:::${aws_s3_bucket.gold_layer.bucket}/*",
      "arn:aws:s3:::${aws_s3_bucket.glue.bucket}/*",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_iam_role_policy" "glue_job_inline_policy" {
  name   = "${var.project}-glue-job-policy"
  role   = aws_iam_role.glue_job_role.id
  policy = data.aws_iam_policy_document.glue_job_policy.json
}

locals {
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess",
    "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
  ]
}

resource "aws_iam_role_policy_attachment" "glue_job_managed_policy_attachment" {
  for_each = toset(local.managed_policy_arns)
  role = aws_iam_role.glue_job_role.name
  policy_arn = each.value
}

# IAM Role for Redshift Serverless
resource "aws_iam_role" "redshift_serverless_role" {
  name               = "${var.project}-redshift-serverless-role"
  assume_role_policy = data.aws_iam_policy_document.redshift_serverless_trust_policy.json
}

data "aws_iam_policy_document" "redshift_serverless_trust_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["redshift.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "redshift_serverless_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetBucketAcl",
      "s3:GetBucketCors",
      "s3:GetEncryptionConfiguration",
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListAllMyBuckets",
      "s3:ListMultipartUploadParts",
      "s3:ListBucketMultipartUploads",
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.gold_layer.bucket}/*"
    ]
  }
}

resource "aws_iam_role_policy" "redshift_serverless_inline_policy" {
  name   = "${var.project}-redshift-serverless-policy"
  role   = aws_iam_role.redshift_serverless_role.id
  policy = data.aws_iam_policy_document.redshift_serverless_policy.json
}
