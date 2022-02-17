# terraform{
# backend "local" {
#    path = "../state/terraform.tfstate"
#  }
#  required_version = ">= 0.14.9"
# }

terraform {
    backend "s3"{

    }
    required_version = ">= 0.14.9"
}
