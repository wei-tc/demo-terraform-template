terraform {
  backend "s3" {
    bucket = "wei-tc-demo-terraform-state"
    key = "mgmt/terraform.tfstate"
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

module "logs" {
  source = "../modules/mgmt/logging"

  project_name = module.global_variables.project_name
  stream_names = ["dashboard-service"]
}