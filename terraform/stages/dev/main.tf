variable "environment" {
  default     = "stage"
  description = "Identifier for Beanstalk Application"
}

variable "application_name" {
  default     = "terraform-test"
  description = "Identifier for Beanstalk Application"
}

variable "database_password" {
  description = "RDS Master user password"
}

module "vpc" {
  source = "../../modules/vpc"
}

module "api" {
  source = "../../modules/beanstalk"
  application_name = "${var.application_name}"
  environment = "${var.environment}"
  vpc_id = "${module.vpc.id}"
  public_subnet_a = "${module.vpc.public_subnet_a}"
  public_subnet_b = "${module.vpc.public_subnet_b}"
}

module "rds" {
  source = "../../modules/rds"
  application_name = "${var.application_name}"
  environment = "${var.environment}"
  private_subnet_a = "${module.vpc.private_subnet_a}"
  private_subnet_b = "${module.vpc.private_subnet_b}"
  engine = "postgres"
  engine_version = "9.5.4"
  storage = "10"
  instance_class = "db.t2.micro"
  database_password = "${var.database_password}"
  vpc_id = "${module.vpc.id}"
  public_subnet_a_cidr_block = "${module.vpc.public_subnet_a_cidr_block}"
  public_subnet_b_cidr_block = "${module.vpc.public_subnet_b_cidr_block}"
  beanstalk_sg_id = "${module.api.beanstalk_sg_id}"
}
