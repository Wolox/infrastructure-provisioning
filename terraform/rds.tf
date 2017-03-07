resource "aws_db_instance" "stage" {
  identifier             = "${var.application_name}-${var.environment}"
  allocated_storage      = "${var.storage}"
  engine                 = "${var.engine}"
  engine_version         = "${lookup(var.engine_version, var.engine)}"
  instance_class         = "${var.instance_class}"
  name                   = "${replace("${var.application_name}", "-", "_")}"
  username               = "${replace("${var.application_name}", "-", "_")}"
  password               = "${var.database_password}"
  vpc_security_group_ids = ["${aws_security_group.rds.id}"]
  db_subnet_group_name   = "${aws_db_subnet_group.stage.id}"
}

resource "aws_db_subnet_group" "stage" {
  name        = "main_subnet_group"
  description = "Our main group of subnets"
  subnet_ids  = ["${aws_subnet.us-east-1b-private.id}", "${aws_subnet.us-east-1d-private.id}"]
}
