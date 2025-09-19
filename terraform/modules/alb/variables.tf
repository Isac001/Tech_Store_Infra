# The ID of the VPC where the Application Load Balancer and its security group will be created.
variable "vpc_id" {
    description = "The ID of the VPC where the ALB will be deployed."
    type        = string
}

# A list of public subnet IDs. The ALB will be deployed across these subnets for high availability.
variable "public_subnet_ids" {
    description = "A list of public subnet IDs where the ALB will be deployed."
    type        = list(string)
}

# The Amazon Resource Name (ARN) of the target group. 
# The ALB's listener will forward incoming requests to this target group.
variable "target_group_arn" {
    description = "ARN of the target group to associate with the ALB."
    type        = string
}