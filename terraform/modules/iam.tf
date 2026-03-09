resource "aws_iam_role" "glue_role" {
  name = "${var.project}-glue-role"
  assume_role_policy = data.aws_iam_policy_document.glue_trust_policy.json
}

data "aws_iam_policy_document" "glue_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "glue_policy" {
    statement {
        actions = [
            "s3:GetObject",
            "s3:PutObject"
        ]
        resources = [
            "arn:aws:s3:::${aws_s3_bucket.bronze_data.bucket}/*",
            "arn:aws:s3:::${aws_s3_bucket.silver_data.bucket}/*",
            "arn:aws:s3:::${aws_s3_bucket.gold_data.bucket}/*",
            "arn:aws:s3:::${aws_s3_bucket.glue.bucket}/*",
        ]
    }
}

resource "aws_iam_role_policy" "glue_inline_policy" {
    name   = "${var.project}-glue-policy"
    role   = aws_iam_role.glue_role.id
    policy = data.aws_iam_policy_document.glue_policy.json
}

# IAM Role for Redshift Serverless
resource "aws_iam_role" "redshift_serverless_role" {
  name = "${var.project}-redshift-serverless-role"
  assume_role_policy = data.aws_iam_policy_document.redshift_serverless_trust_policy.json
}

data "aws_iam_policy_document" "redshift_serverless_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["redshift.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "redshift_serverless_policy" {
    statement {
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
            "arn:aws:s3:::${aws_s3_bucket.gold_data.bucket}/*"
        ]
    }
}

resource "aws_iam_role_policy_attachment" "redshift_serverless_inline_policy" {
  role       = aws_iam_role.redshift_serverless_role.name
  policy_arn = data.aws_iam_policy.redshift_serverless_policy.arn
}