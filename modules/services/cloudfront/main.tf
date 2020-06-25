resource "aws_cloudfront_distribution" "main" {
  origin {
    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols = [
        "TLSv1"]
    }
    domain_name = var.origin_domain_name
    origin_id = var.origin_id
  }

  price_class = "PriceClass_100"
  enabled = true

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  default_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD"]
    cached_methods = [
      "GET",
      "HEAD"]
    target_origin_id = var.origin_id
    viewer_protocol_policy = "allow-all"
    trusted_signers = ["self"]

    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }

    min_ttl = 0
    default_ttl = 1000
    max_ttl = 86400
  }

  ordered_cache_behavior {
    path_pattern = "static/*"
    allowed_methods = [
      "GET",
      "HEAD",
      "OPTIONS"]
    cached_methods = [
      "GET",
      "HEAD"]
    target_origin_id = var.origin_id

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    min_ttl = 0
    default_ttl = 1000
    max_ttl = 86400
    viewer_protocol_policy = "allow-all"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  logging_config {
    bucket = var.s3_logging_bucket
    prefix = var.project_name
  }

  tags = {
    project = var.project_name
  }
}