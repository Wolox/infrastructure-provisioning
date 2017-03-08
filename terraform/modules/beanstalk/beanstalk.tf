variable "environment" {}
variable "application_name" {}
variable "vpc_id" {}
variable "public_subnet_a" {}
variable "public_subnet_b" {}

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
    value     = "${var.vpc_id}"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = "${var.public_subnet_a}, ${var.public_subnet_b}"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = "true"
  }
}
