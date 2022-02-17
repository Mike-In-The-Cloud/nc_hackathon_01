
data "aws_region" "current" {}

variable "stack_name" {
  type = string
} 
variable "function_name" {
  type    = string
  
}
variable "handler_name" {
  type    = string
}
variable "runtime" {
  type    = string
}
variable "timeout" {
  type    = string
}


variable "bucket_name" {
  default=""
  
}

variable "account_id"{
  type = string
}

# Input variable definitions

variable "aws_region" {
  description = "AWS region for all resources."

  type    = string
  default = "eu-west-2"
}
