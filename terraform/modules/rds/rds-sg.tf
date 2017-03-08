variable "vpc_id" {}
variable "public_subnet_a_cidr_block" {}
variable "public_subnet_b_cidr_block" {}

resource "aws_security_group" "rds" {
  name        = "rds-${var.environment}-sg"
  description = "Allow all inbound traffic"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "TCP"
    cidr_blocks = ["${var.public_subnet_a_cidr_block}", "${var.public_subnet_b_cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}