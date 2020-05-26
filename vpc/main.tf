terraform {
  backend "s3" {
    bucket = "wei-tc-demo-terraform-state"
    key = "vpc/terraform.tfstate"
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

module "vpc" {
  source = "../modules/vpc"

  project_name = module.global_variables.project_name

  enable_dns_hostnames = true
  enable_dns_support = true
  vpc_cidr = "10.0.0.0/16"

  public_subnet_cidrs = [
    "10.0.1.0/24",
    "10.0.2.0/24"]
  private_subnet_cidrs = [
    "10.0.3.0/24",
    "10.0.4.0/24"]
}
