terraform {
  backend "s3" {
    bucket = "wei-tc-demo-terraform-state"
    key = "global/s3/terraform.tfstate"
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
  source = "../variables"
}

module "security" {
  source = "../../modules/security/s3"

  project_name = module.global_variables.project_name

  terraform_remote_state_bucket = module.global_variables.terraform_remote_state_bucket
  terraform_remote_state_dynamodb = module.global_variables.terraform_remote_state_dynamodb

  env_key = "${module.global_variables.project_name}.env"
  env_source = "prod.env"
}

