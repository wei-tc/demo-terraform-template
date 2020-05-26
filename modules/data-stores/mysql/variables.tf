variable "project_name" {
  description = "The project name to be used for resource tags"
  type = string
}

variable "db_name" {
  description = "The name of the db"
  type = string
}

variable "db_username" {
  description = "The username of the db"
  type = string
}

variable "db_password" {
  description = "The password of the db"
  type = string
}

variable "private_subnet_ids" {
  description = "RDS DB subnet ids"
  type = list(string)
}

variable "private_sg_id" {
  type = string
}

variable "skip_final_snapshot" {
  type = bool
  default = false
}
