variable "aws_region" {
  type        = string
  description = "the region to deploy resources"

}

# VPC
variable "vpc_cidr" {
  description = "cidr block for vpc"
  type        = string

}

variable "vpc_name" {
  description = "name of vpc"
  type        = string


}

## All subnets
variable "public_subnet_1" {
  description = "public subnet 1"
  type        = string

}

variable "public_subnet_2" {
  description = "public subnet 2"
  type        = string
}

variable "private_subnet_1" {
  description = "private subnet 1"
  type        = string

}

variable "private_subnet_2" {
  description = "private subnet 2"
  type        = string

}

variable "public_subnet_1_cidr" {
  description = "public 1 cidr block"
  type        = string

}

variable "public_subnet_2_cidr" {
  description = "public 2 cidr block"
  type        = string

}

variable "private_subnet_1_cidr" {
  description = "private1 cidr block"
  type        = string

}

variable "private_subnet_2_cidr" {
  description = "private 2 cidr block"
  type        = string

}

variable "a_z_1" {
  description = "availability zone 1"
  type        = string
}

variable "a_z_2" {
  description = "availability zone 2"
  type        = string
}

variable "hosted_zone_name" {
  description = "domain name"
  type        = string
}