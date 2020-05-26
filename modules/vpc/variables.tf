variable "project_name" {
  description = "The project name to be used for resource tags"
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "enable_dns_support" {
  type = bool
}

variable "enable_dns_hostnames" {
  type = bool
}

variable "private_routes" {
  type = list(object({
    cidr_block = string
    gateway_id = string
    instance_id = string
    nat_gateway_id = string
  }))
  default = []
}

variable "public_routes" {
  type = list(object({
    cidr_block = string
    gateway_id = string
    instance_id = string
    nat_gateway_id = string
  }))
  default = []
}

variable "rds_port" {
  type = number
  default = 3306
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
}
