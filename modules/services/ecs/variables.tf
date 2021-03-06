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
  default = []
}

variable "service_name" {
  type = string
}

variable "desired_service_count" {
  type = number
}

variable "deployment_minimum_percent" {
  type = number
}

variable "deployment_maximum_percent" {
  type = number
}

variable "ordered_placement_strategy" {
  type = object({
    type = string
    field = string
  })
  default = {
    type = "random"
    field = ""
  }

}

variable "container_name" {
  type = string
}

variable "ecs_task_execution_s3_env_policy" {
  type = string
}

variable "ecs_task_s3_static_policy" {
  type = string
}
