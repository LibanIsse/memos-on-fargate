variable "private_subnet_1_id" {
  description = "private subnet 1"
  type        = string
}

variable "private_subnet_2_id" {
  description = "private subnet 2"
  type        = string
}

variable "vpc_id" {
  description = "vpc"
  type        = string
}

variable "task_sg" {
  description = "task security group"
  type        = string
}

variable "db_name" {
  type    = string
  default = "database1"
}

variable "db_username" {
  type    = string
  default = "postgres"
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "allocated_storage" {
  type    = number
  default = 20
}

