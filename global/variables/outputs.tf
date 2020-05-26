output "project_name" {
  description = "The project name to be used for resource tags"
  value = "wei-tc-demo"
}

output "terraform_remote_state_bucket" {
  description = "The name of the s3 bucket storing global terraform state"
  value = "wei-tc-demo-terraform-state"
}

output "terraform_remote_state_dynamodb" {
  description = "The name of the dynamodb_table used to store locks for the global terraform state"
  value = "wei-tc-demo-terraform-locks"
}

output "region" {
  value = "us-west-2"
}