provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

resource "aws_launch_configuration" "example" {
  image_id = "ami-083654bd07b5da81d"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.sgweb.id]
  user_data = <<-EOF
                #!/bin/bash
                echo "Hello, World !!!" > index.html
                nohup busybox httpd -f -p ${var.server_port} &
                EOF
  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier = data.aws_subnet_ids.default.ids
  target_group_arns = [aws_lb_target_group.tgasg.arn]
  health_check_type = "ELB"
  min_size = 2
  max_size = 10
  desired_capacity = 3
}

resource "aws_security_group" "sgweb" {
    name = "sgWeb"
    ingress {
        from_port = var.server_port
        to_port = var.server_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
}

resource "aws_lb" "example" {
  name = "albWeb"
  load_balancer_type = "application"
  subnets = data.aws_subnet_ids.default.ids
  security_groups = [aws_security_group.sgalb.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code = 404
    }
  }
}

resource "aws_security_group" "sgalb" {
    name = "sgAlb"
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_lb_target_group" "tgasg" {
  name = "tgAsg"
  port = var.server_port
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default.id 
  health_check {
      path = "/"
      protocol = "HTTP"
      matcher = "200"
      interval = 15
      timeout = 3
      healthy_threshold = 2
      unhealthy_threshold = 2

  }
}

resource "aws_lb_listener_rule" "static" {
  listener_arn = aws_lb_listener.http.arn
  priority = 100
  condition {
    path_pattern {
      values = [ "*" ]
    }
  }
  action {
      type = "forward"
      target_group_arn = aws_lb_target_group.tgasg.id
  }
}


