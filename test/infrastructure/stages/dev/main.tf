variable "environment" {
  default     = "dev"
  description = "Identifier for Beanstalk Application"
}

variable "application_name" {
  default     = "terraform"
  description = "Identifier for Beanstalk Application"
}

variable "database_password" {
  description = "RDS Master user password"
}



module "api" {
  source = "../../modules/beanstalk"
  application_name = "${var.application_name}"
  environment = "${var.environment}"
  instance_type = "t2.medium"

  
}

module "rds" {
  source = "../../modules/rds"
  application_name = "${var.application_name}"
  environment = "${var.environment}"
  engine = "postgres"
  engine_version = "9.5.4"
  storage = "10"
  instance_class = "db.t2.micro"
  database_password = "${var.database_password}"
  beanstalk_sg_id = "${module.api.beanstalk_sg_id}"

  
}
