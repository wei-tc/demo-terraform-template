terraform {
  backend "s3" {
    bucket = "wei-tc-demo-terraform-state"
    key = "services/terraform.tfstate"
    region = "us-west-2"
    dynamodb_table = "wei-tc-demo-terraform-locks"
    encrypt = true
    profile = "demo"
  }
}

provider "aws" {
  region = "us-west-2"
  profile = "demo"
}

module "global_variables" {
  source = "../global/variables"
}

data "template_file" "s3_public_policy" {
  template = file("../modules/services/s3/s3-public-policy.json")
  vars = {
    bucket = module.global_variables.project_name
  }
}

module "staticfiles" {
  source = "../modules/services/s3"

  project_name = module.global_variables.project_name
  s3_bucket_name = module.global_variables.project_name

  cors_rule = {
    allowed_headers = ["*"]
    allowed_methods = ["POST", "PUT", "DELETE"]
    allowed_origins = ["*"]
    expose_headers = ["ETag"]
    max_age_seconds = 3000
  }

  s3_policy = data.template_file.s3_public_policy.rendered
}

resource "aws_s3_bucket" "www_redirect" {
  bucket = "www.${module.global_variables.project_name}"
  acl = "public-read"

  website {
    redirect_all_requests_to = "www.${module.global_variables.project_name}"
  }

  tags = {
    project = module.global_variables.project_name
  }
}

data "template_file" "ecs-task-s3-static-readwrite" {
  template = file("../modules/services/ecs/s3-task-static-policy.json")
  vars = {
    bucket = module.global_variables.project_name
  }
}
data "template_file" "ecs-task-execution-s3-env-read" {
  template = file("../modules/services/ecs/s3-task-execution-env-policy.json")
  vars = {
    bucket = module.global_variables.project_name
  }
}

module "demo" {
  source = "../modules/services/ecs"

  project_name = module.global_variables.project_name
  public_security_group_id = data.aws_security_group.public.id
  public_subnet_ids = data.aws_subnet_ids.public.ids
  vpc_id = data.aws_vpc.main.id

  ecs_key_pair_name = file("key-pair.env")

  container_definitions = file("service.json")
  family = "demo"
  service_name = "demo"
  container_name = "nginx"
  desired_service_count = 1
  volume_name = ["static_volume", "media_volume"]

  ecs-task-execution-s3-env-policy = data.template_file.ecs-task-execution-s3-env-read.rendered
  ecs-task-s3-static-policy = data.template_file.ecs-task-s3-static-readwrite.rendered
}

data "aws_security_group" "public" {
  filter {
    name = "tag:project"
    values = [
      module.global_variables.project_name
    ]
  }

  filter {
    name = "tag:public"
    values = [
      true
    ]
  }
}

data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.main.id

  filter {
    name = "tag:public"
    values = [
      true
    ]
  }
}

data "aws_vpc" "main" {
  filter {
    name = "tag:project"
    values = [
      module.global_variables.project_name
    ]
  }
}
