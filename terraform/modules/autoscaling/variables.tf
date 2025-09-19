# A list of public subnet IDs where the Auto Scaling Group will launch new instances.
variable "public_subnet_ids" {
    description = "A list of public subnet IDs where the Auto Scaling Group will launch instances."
    type        = list(string)
}

# The ID of the EC2 Launch Template, which defines the configuration (AMI, instance type, etc.) 
# for the instances that the Auto Scaling Group will create.
variable "launch_template_id" {
    description = "The ID of the launch template to use for the Auto Scaling Group."
    type        = string
}

# The Amazon Resource Name (ARN) of the Application Load Balancer's target group.
# New instances will be automatically registered with this target group to receive traffic.
variable "target_group_arn" {
    description = "ARN of the target group to associate with the Auto Scaling Group."
    type        = string
}