data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# data "lambda_function" "existing" {
#   function_name = "${var.function_name}"
# }