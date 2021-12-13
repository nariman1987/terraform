provider "aws" {
    region = "us-east-1"
}


terraform {
  backend "s3" {
    key = "global/s3/terraform.tfstate"  
    bucket = "bucket-nariman-lab-tech"
    region = "us-east-1"
    dynamodb_table = "terraformUpAndRunningLocks"
    encrypt = true
  }
}


resource "aws_s3_bucket" "terraform_state" {
  bucket = "bucket-nariman-lab-tech"
  lifecycle {
    prevent_destroy = false
  }
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "terreformLocks" {
  name = "terraformUpAndRunningLocks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}



