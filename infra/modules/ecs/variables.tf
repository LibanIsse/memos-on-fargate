variable "execution_role_arn" {
  type = string
}

variable "private_subnet_1_id" {
  type = string
}

variable "private_subnet_2_id" {
  type = string
}

variable "task_sg_id" {
  type = string
}

variable "target_group_arn" {
  type = string
}


variable "task_family" {
  type    = string
  default = "memos-td"
}

variable "container_name" {
  type    = string
  default = "memos"
}

variable "container_port" {
  type    = number
  default = 5230
}

variable "ecs_cpu" {
  type    = string
  default = "512"
}

variable "ecs_memory" {
  type    = string
  default = "1024"
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "log_group_name" {
  type    = string
  default = "/ecs/memos-logs"
}

variable "log_retention_days" {
  type    = number
  default = 7
}

variable "container_image" {
  type    = string
  default = "527814729206.dkr.ecr.eu-west-2.amazonaws.com/ecsmemos:latest"
}

variable "memos_dsn" {
  type      = string
  sensitive = true
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "cluster_name" {
  description = "ECS cluster name"
  type        = string
}

variable "service_name" {
  description = "ECS service name"
  type        = string
}