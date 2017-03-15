resource "aws_security_group" "beanstalk" {
  name        = "beanstalk-${var.environment}-sg"
  description = "Beanstalk EC2 Security Group"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
