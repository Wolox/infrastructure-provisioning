variable "environment" {}
variable "application_name" {}
variable "has_vpc" {}
variable "vpc_id" {}
variable "public_subnet_a" {}
variable "public_subnet_b" {}
variable "instance_type" {}

resource "aws_elastic_beanstalk_application" "stage" {
  name = "${var.application_name}"
  description = "${var.application_name}-${var.environment}"
}

resource "aws_elastic_beanstalk_environment" "stage" {
  name = "${var.application_name}-${var.environment}"
  application = "${aws_elastic_beanstalk_application.stage.name}"
  solution_stack_name = "64bit Amazon Linux 2016.09 v2.3.1 running Ruby 2.3 (Puma)"
  cname_prefix = "${var.application_name}-${var.environment}"

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = "${var.has_vpc ? var.vpc_id : ""}"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = "${var.has_vpc ? "${var.public_subnet_a}, ${var.public_subnet_b}" : "" }"
  }

  setting {
    namespace = "${var.has_vpc ? "aws:ec2:vpc" : ""}"
    name      = "${var.has_vpc ? "AssociatePublicIpAddress" : ""}"
    value     = "${var.has_vpc ? "true" : ""}"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = "${aws_security_group.beanstalk.id}"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "InstanceType"
    value = "${var.instance_type}"
  }
}