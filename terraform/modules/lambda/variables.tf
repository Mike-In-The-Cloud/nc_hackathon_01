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

variable "stack_name" {
  type = string
} 


variable "bucket_name" {
  default=""
  
}

variable "account_id"{
  type = string
}