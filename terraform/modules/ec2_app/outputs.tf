# This output will display the unique ID of the EC2 instance created by this configuration.
# It's useful for referencing the instance in other operations or scripts.
output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.main.id
}

# This output provides the public IP address assigned to the EC2 instance.
# You can use this IP to access the application running on the server or to SSH into it.
output "public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.main.public_ip
}

# This output shows the ID of the security group.
# This can be helpful for auditing, troubleshooting, or linking other resources to this security group.
output "security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.main.id
}

output "target_group_arn" {
  description = "The ARN of the Load Balancer Target Group"
  value       = aws_lb_target_group.main.arn
  
}

output "launch_template_id" {
  description = "The ID of the Launch Template"
  value       = aws_launch_template.main.id
  
}

output "target_group_name" {
  description = "The name of the Load Balancer Target Group"
  value       = aws_lb_target_group.main.name
  
}