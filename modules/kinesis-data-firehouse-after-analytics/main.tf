/*
* Define the Kinessis Data firehouse
*/


resource "aws_kinesis_firehose_delivery_stream" "extended_s3_stream" {
  name        = "sg12-kinesis-firehose-processed-s3-stream"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn        = aws_iam_role.kinesis_firehose_role.arn
    bucket_arn      = aws_s3_bucket.bucket.arn
    buffer_interval = 60
    buffer_size     = 5

    processing_configuration {
      enabled = "false"
    }

    cloudwatch_logging_options {
      enabled         = "true"
      log_group_name  = "sg12/sg12-kinesis-firehose-processed-s3-stream"
      log_stream_name = "customstream"

    }
  }

}




/*
* Delivery Bucket
*/


resource "aws_s3_bucket" "bucket" {
  bucket = "sg12-tf-processed-bucket"
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "private"
}



/*
* Kinessis Roles
*/

resource "aws_iam_role" "kinesis_firehose_role" {
  name = "kinesis_processed_firehose_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
      }
    ]
  })

}

resource "aws_iam_policy" "kinesis_firehose_policy" {
  name = "kinesis_processed_firehose_policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:FilterLogEvents"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
            "s3:AbortMultipartUpload",
            "s3:GetBucketLocation",
            "s3:GetObject",
            "s3:ListBucket",
            "s3:ListBucketMultipartUploads",
            "s3:PutObject"
        ],
        "Resource": "${aws_s3_bucket.bucket.arn}",
        "Resource": "${aws_s3_bucket.bucket.arn}/*"
      }
    ]
}
EOF
}

/*
*  Attach policty to Role
*/


resource "aws_iam_role_policy_attachment" "kinesis_processed_policy_to_role" {
  role       = aws_iam_role.kinesis_firehose_role.name
  policy_arn = aws_iam_policy.kinesis_firehose_policy.arn
}

