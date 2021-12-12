provider "aws" {
  region = "us-east-1"
}

output "public_ip" {
    description = "The public IP"
    value = aws_instance.example-web.public_ip
}

variable "server_port" {
    description = "Server Port"
    type = number
    default = 8080
}

resource "aws_instance" "example" {
  ami = "ami-0ed9277fb7eb570c9"
  instance_type = "t2.micro"
  tags = {
      name = "terraform-example"
  }
}

resource "aws_instance" "example-web" {
    ami = "ami-083654bd07b5da81d"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.sg-example-web.id]
    user_data = <<-EOF
                #!/bin/bash
                echo "Hello, World !!!" > index.html
                nohup busybox httpd -f -p ${var.server_port} &
                EOF
    tags = {
        name = "terraform-web-example"
    }   
}


resource "aws_security_group" "sg-example-web" {
    name = "terraform-example-web"
    ingress {
        from_port = var.server_port
        to_port = var.server_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
}