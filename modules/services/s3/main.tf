resource "aws_s3_bucket" "s3" {
  bucket = var.s3_bucket_name
  policy = var.s3_policy

  cors_rule {
    allowed_headers = lookup(var.cors_rule, "allowed_headers", null)
    allowed_methods = lookup(var.cors_rule, "allowed_methods", null)
    allowed_origins = lookup(var.cors_rule, "allowed_origins", null)
    expose_headers = lookup(var.cors_rule, "expose_headers", null)
    max_age_seconds = lookup(var.cors_rule, "max_age_seconds", null)
  }

  tags = {
    project = var.project_name
  }
}

resource "aws_ssm_parameter" "name" {
  name = "/s3/${var.project_name}/name"
  description = "${var.project_name} s3 name"
  type = "SecureString"
  value = "${var.s3_bucket_name}-s3"
}