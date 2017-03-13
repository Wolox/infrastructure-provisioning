variable "bucket_name" {}

data "template_file" "init" {
    template = "${file("../../modules/s3/policy.tpl")}"

    vars {
        bucket_name = "${var.bucket_name}"
    }
}

resource "aws_s3_bucket" "b" {
    bucket = "${var.bucket_name}"
    acl = "public-read"
    policy = "${data.template_file.init.rendered}"

    cors_rule {
        allowed_headers = ["Authorization"]
        allowed_methods = ["GET"]
        allowed_origins = ["*"]
        max_age_seconds = 3000
    }
}
