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

variable "has_vpc" {
  default     = false
  description = "RDS Master user password"
}

/*module "vpc" {
  source = "../../modules/vpc"
}*/

module "api" {
  source = "../../modules/beanstalk"
  application_name = "${var.application_name}"
  environment = "${var.environment}"
  has_vpc = "${var.has_vpc}"
  /*vpc_id = "${module.vpc.id}"
  public_subnet_a = "${module.vpc.public_subnet_a}"
  public_subnet_b = "${module.vpc.public_subnet_b}"*/
  vpc_id = ""
  public_subnet_a = ""
  public_subnet_b = ""
  instance_type = "t2.medium"
}

module "rds" {
  source = "../../modules/rds"
  application_name = "${var.application_name}"
  environment = "${var.environment}"
  /*private_subnet_a = "${module.vpc.private_subnet_a}"
  private_subnet_b = "${module.vpc.private_subnet_b}"
  vpc_id = "${module.vpc.id}"*/
  engine = "postgres"
  engine_version = "9.5.4"
  storage = "10"
  instance_class = "db.t2.micro"
  database_password = "${var.database_password}"

  beanstalk_sg_id = "${module.api.beanstalk_sg_id}"
}
