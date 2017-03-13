variable "bucket_name" {
  default     = "www.terraform-test.com"
  description = "Bucket name"
}

module "s3" {
  source = "../../modules/s3"
  bucket_name = "${var.bucket_name}"
}
