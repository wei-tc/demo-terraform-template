variable "project_name" {
  description = "The project name to be used for resource tags"
  type = string
}

variable "public_security_group_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "ecs_key_pair_name" {
  type = string
}

variable "container_definitions" {
  type = string
}

variable "family" {
  description = "Task definition family"
  type = string
}

variable "volume_name" {
  type = list(string)
}

variable "service_name" {
  type = string
}

variable "desired_service_count" {
  type = number
}

variable "container_name" {
  type = string
}

variable "ecs-task-execution-s3-env-policy" {
  type = string
}

variable "ecs-task-s3-static-policy" {
  type = string
}
