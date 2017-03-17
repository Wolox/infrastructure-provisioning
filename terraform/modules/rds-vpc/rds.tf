variable "environment" {}
variable "application_name" {}
variable "private_subnet_a" {}
variable "private_subnet_b" {}
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
  db_subnet_group_name   = "${aws_db_subnet_group.stage.id}"
}

resource "aws_db_subnet_group" "stage" {
  name        = "rds-${var.application_name}-${var.environment}"
  subnet_ids  = ["${var.private_subnet_a}", "${var.private_subnet_b}"]
}