data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "session_recording" {
  statement {
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectAttributes",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.session_recording.arn,
      "${aws_s3_bucket.session_recording.arn}/*",
    ]
  }
}

resource "aws_iam_role" "workers" {
  name               = "boundary-workers"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  inline_policy {
    name   = "s3"
    policy = data.aws_iam_policy_document.session_recording.json
  }
}

resource "aws_iam_instance_profile" "workers" {
  name = "boundary-worker-instance-profile"
  role = aws_iam_role.workers.name
}
