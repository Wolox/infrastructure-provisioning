variable "application_name" {
  default     = "terraform-test"
  description = "Identifier for Beanstalk Application"
}

variable "environment" {
  default     = "stage"
  description = "Identifier for Beanstalk Application"
}

variable "storage" {
  default     = "10"
  description = "Storage size in GB"
}

variable "engine" {
  default     = "postgres"
  description = "Engine type, example values mysql, postgres"
}

variable "engine_version" {
  description = "Engine version"

  default = {
    mysql    = "5.6.22"
    postgres = "9.5.4"
  }
}

variable "instance_class" {
  default     = "db.t2.micro"
  description = "Instance class"
}

variable "database_password" {
  description = "password, provide through your ENV variables"
}
