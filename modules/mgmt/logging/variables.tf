variable "project_name" {
  description = "The project name to be used for resource tags"
  type = string
}

variable "stream_names" {
  type = list(string)
  default = []
}

variable "retention_in_days" {
  type = string
  default = "1"
}
