# Set the AWS region
variable "aws_region" {
  description = "The AWS region to create resources in"
  type        = string
  default     = "us-west-2"
}

# Set the environment name
variable "notification_email" {
  description = "Email address for SNS notifications"
  type        = string
  
}