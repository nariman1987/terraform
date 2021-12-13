provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    key = "stage/services/webservercluster/terraform.tfstate"  
    bucket = "bucket-nariman-lab-tech"
    region = "us-east-1"
    dynamodb_table = "terraformUpAndRunningLocks"
    encrypt = true
  }
}


module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"
  key = "stage/datastores/postgres/terraform.tfstate"
  bucket = "bucket-nariman-lab-tech"
  cluster_name = "test"
}

output "alb_dns_name" {
  value = module.webserver_cluster.alb_dns_name
}


resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  scheduled_action_name = "scale-out-during-business-hours"
  min_size = 2
  max_size = 6
  desired_capacity = 4
  recurrence = "0 9 * * *"
  autoscaling_group_name = module.webserver_cluster.asg_name
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  scheduled_action_name = "scale-in-at-night"
  min_size = 2
  max_size = 6
  desired_capacity = 2
  recurrence = "0 17 * * *"
  autoscaling_group_name = module.webserver_cluster.asg_name
}



