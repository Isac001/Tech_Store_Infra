# VPC Module Variables  

# Region where the VPC will be created
variable "aws_region" {
  description = "The AWS region to create resources in."
  type = string
  default = "us-east-1"
}