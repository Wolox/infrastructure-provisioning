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
    value     = "${aws_vpc.stage.id}"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = "${aws_subnet.us-east-1b-public.id}"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = "true"
  }
}
