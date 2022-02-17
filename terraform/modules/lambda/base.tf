
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "../../python/lambda_function.py"
  output_path = "lambda_function.zip"
}

# Creating Lambda IAM resource
resource "aws_iam_role" "iam_for_lambda_tf" {
  name = "iam_for_lambda_tf"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_s3_put" {
  name   = "lambda-logs"
  role   = aws_iam_role.iam_for_lambda_tf.name
   policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:CopyObject",
        "s3:HeadObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::hackathon001-${var.account_id}-backend",
        "arn:aws:s3:::hackathon001-${var.account_id}-backend/*"
      ]
    },
    {
      "Action": [
        "s3:ListBucket",
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:CopyObject",
        "s3:HeadObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::hackathon001-${var.account_id}-backend",
        "arn:aws:s3:::hackathon001-${var.account_id}-backend/*"
      ]
    },
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}


resource "aws_lambda_function" "hackaton_lambda" {
  function_name    = var.function_name
  role             = aws_iam_role.iam_for_lambda_tf.arn
  handler          = "${var.handler_name}.lambda_handler"
  runtime          = var.runtime
  timeout          = var.timeout
  filename         = "${var.handler_name}.zip"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  publish          = true

  tags = {
    Name        = "Hackathon Python Lambda Code"
    Environment = "LaunchPad"
  }

  # Make sure the role policy is attached before trying to use the role
  depends_on = [aws_iam_role_policy.lambda_s3_put]
}
