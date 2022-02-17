resource "aws_kms_key" "s3_backend_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 30
}

resource "aws_kms_alias" "s3_backend_key_alias" {
  name          = "alias/Hackathon_Terraform_Backend"
  target_key_id = aws_kms_key.s3_backend_key.key_id
}

resource "aws_s3_bucket" "aws_s3_bucket_backend" {
  bucket = "${var.stack_name}-${data.aws_caller_identity.current.account_id}-backend"
  acl    = "private"
  
  versioning {
    enabled = true
  }
  tags = {
    Name = "hackathon-s3-lambda"
  }


server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.s3_backend_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}


# creating folder objects in S3
resource "aws_s3_bucket_object" "inputs" {
    bucket = "${aws_s3_bucket.aws_s3_bucket_backend.id}"
    acl    = "private"
    key    = "inputs/"
    source = "/dev/null"
}
resource "aws_s3_bucket_object" "outputs" {
    bucket = "${aws_s3_bucket.aws_s3_bucket_backend.id}"
    acl    = "private"
    key    = "outputs/"
    source = "/dev/null"
}

# # trigger
resource "aws_s3_bucket_notification" "aws-lambda-trigger" {
bucket = "${aws_s3_bucket.aws_s3_bucket_backend.id}"
lambda_function {
lambda_function_arn = "arn:aws:lambda:eu-west-2:${var.account_id}:function:hackathon_lambda"
events              = ["s3:ObjectCreated:*"]
filter_prefix       = "/inputs/*"
filter_suffix       = ".json"
}
}
resource "aws_lambda_permission" "test" {
statement_id  = "AllowS3Invoke"
action        = "lambda:InvokeFunction"
function_name = "${var.function_name}"
principal = "s3.amazonaws.com"
source_arn = "arn:aws:s3:::hackathon001-${var.account_id}-backend"
}
