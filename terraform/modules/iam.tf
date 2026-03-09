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
            "arn:aws:s3:::${aws_s3_bucket.raw_data.bucket}/*"
        ]
    }
}

resource "aws_iam_role_policy" "glue_inline_policy" {
    name   = "${var.project}-glue-policy"
    role   = aws_iam_role.glue_role.id
    policy = data.aws_iam_policy_document.glue_policy.json
}