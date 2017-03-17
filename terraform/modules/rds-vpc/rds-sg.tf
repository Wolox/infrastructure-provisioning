variable "vpc_id" {}
variable "beanstalk_sg_id" {}

resource "aws_security_group" "rds" {
  name        = "rds-${var.environment}-sg"
  description = "Allow all inbound traffic"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "TCP"
    security_groups = ["${var.beanstalk_sg_id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
