# Defines the name for the Lambda function.
variable "function_name" {
    description = "The name of the Lambda function."
    type        = string
}

# The name of the Auto Scaling group that the Lambda function will target for its test.
variable "autoscaling_group_name" {
    description = "The name of the Auto Scaling group for the Lambda function to interact with."
    type        = string
}

# The Amazon Resource Name (ARN) of the SNS topic where the Lambda function will publish its results.
variable "sns_topic_arn" {
    description = "The ARN of the SNS topic to send alerts to."
    type        = string
}

# The AWS region where the Lambda function and related resources will be deployed.
variable "aws_region" {
    
    description = "The AWS region where the Lambda function will be deployed."
    type        = string

    # Sets a default value for the region, which can be overridden if needed.
    default     = "us-west-2"
}