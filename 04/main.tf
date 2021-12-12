provider "aws" {
    region = "us-east-1"
}

# terraform {
#   backend "s3" {
#     bucket = "bucket-nariman-lab-tech"
#     dynamodb_table = "terraformUpAndRunningLocks"
#     key = "workspacesexample/terraform.tfstate"
#     encrypt = true
#     region = "us-east-1"
#   }
# }

resource "aws_instance" "example" {
  ami = "ami-0ed9277fb7eb570c9"
  instance_type = terraform.workspace == "default" ? "t2.nano" : "t2.micro"
}

# resource "aws_s3_bucket" "terraform_state" {
#   bucket = "bucket-nariman-lab-tech"
#   lifecycle {
#     prevent_destroy = false
#   }
#   versioning {
#     enabled = true
#   }
#   server_side_encryption_configuration {
#     rule {
#       apply_server_side_encryption_by_default {
#         sse_algorithm = "AES256"
#       }
#     }
#   }
# }

# resource "aws_dynamodb_table" "terreformLocks" {
#   name = "terraformUpAndRunningLocks"
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key = "LockID"
#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }

