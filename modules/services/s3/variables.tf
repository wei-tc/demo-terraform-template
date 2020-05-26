variable "project_name" {
  description = "The project name to be used for resource tags"
  type = string
}

variable "s3_bucket_name" {
  description = "The name to use for s3"
  type = string
}

variable "s3_policy" {
  description = "s3 bucket policy"
  type = string
}

variable "cors_rule" {
  description = "Cross-origin resource sharing rule - allowed headers"
  type = object({
    allowed_headers = list(string)
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers = list(string)
    max_age_seconds = number
  })
}

