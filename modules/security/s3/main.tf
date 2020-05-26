resource "aws_s3_bucket" "terraform_state" {
  bucket = var.terraform_remote_state_bucket

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    project = var.project_name
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name = var.terraform_remote_state_dynamodb
  billing_mode = "PROVISIONED"
  read_capacity = 25
  write_capacity = 25

  hash_key = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    project = var.project_name
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_s3_bucket" "env" {
  bucket = "${var.project_name}-env"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    project = var.project_name
  }
}

resource "aws_s3_bucket_object" "env" {
  bucket = aws_s3_bucket.env.bucket
  key = var.env_key
  source = var.env_source
  etag = filemd5(var.env_source)
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.env.bucket

  block_public_acls = true
  block_public_policy = true
  restrict_public_buckets = true
  ignore_public_acls = true
}