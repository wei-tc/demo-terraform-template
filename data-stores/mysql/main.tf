terraform {
  backend "s3" {
    bucket = "wei-tc-demo-terraform-state"
    key = "data-stores/mysql/terraform.tfstate"
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
  source = "../../global/variables"
}

data "aws_vpc" "main" {
  filter {
    name = "tag:project"
    values = [module.global_variables.project_name]
  }
}

data "aws_security_group" "private" {
  filter {
    name = "tag:project"
    values = [module.global_variables.project_name]
  }

  filter {
    name = "tag:private"
    values = [true]
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.main.id

  filter {
    name = "tag:private"
    values = [true]
  }
}

module "rds_mysql" {
  source = "../../modules/data-stores/mysql"

  project_name = module.global_variables.project_name

  db_name = yamldecode(file("db.yml"))["db_name"]
  db_username = yamldecode(file("db.yml"))["db_username"]
  db_password = yamldecode(file("db.yml"))["db_password"]

  skip_final_snapshot = true

  private_sg_id = data.aws_security_group.private.id
  private_subnet_ids = data.aws_subnet_ids.private.ids
}
