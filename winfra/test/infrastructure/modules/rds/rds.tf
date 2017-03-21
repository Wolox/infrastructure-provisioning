variable "environment" {}
variable "application_name" {}
variable "engine" {}
variable "engine_version" {}
variable "storage" {}
variable "instance_class" {}
variable "database_password" {}


resource "aws_db_instance" "stage" {
  identifier             = "${var.application_name}-${var.environment}"
  allocated_storage      = "${var.storage}"
  engine                 = "${var.engine}"
  engine_version         = "${var.engine_version}"
  instance_class         = "${var.instance_class}"
  name                   = "${replace("${var.application_name}", "-", "_")}"
  username               = "${replace("${var.application_name}", "-", "_")}"
  password               = "${var.database_password}"
  vpc_security_group_ids = ["${aws_security_group.rds.id}"]
  
}


