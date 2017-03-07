resource "aws_security_group" "rds" {
  name        = "rds-${var.environment}-sg"
  description = "Allow all inbound traffic"
  vpc_id      = "${aws_vpc.stage.id}"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "TCP"
    cidr_blocks = ["${aws_subnet.us-east-1b-public.cidr_block}", "${aws_subnet.us-east-1d-public.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
