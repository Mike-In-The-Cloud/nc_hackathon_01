module "lambda_terraform_hackaton_backend" {
    source      = "../modules/s3-bucket"

    # Variables
    stack_name  = var.stack_name
    function_name = var.function_name
    account_id = var.account_id
}

module "lambda_function"{
    source="../modules/lambda"
    stack_name  = var.stack_name
    function_name=var.function_name
    handler_name=var.handler_name
    runtime=var.runtime
    timeout=var.timeout 
    account_id    = var.account_id
}