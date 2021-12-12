provider "aws" {
    region = "us-east-1"
}

resource "aws_db_instance" "example" {
  identifier_prefix = "terraform-up-and-running"
  engine = "postgres"
  engine_version = "12.4"
  allocated_storage = 10
  instance_class = "db.t2.micro"
  name = "example_database"
  username = "postgres"
  password = "alpha2021test"
}