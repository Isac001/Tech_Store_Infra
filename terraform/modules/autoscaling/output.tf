# Output the name of the Autoscaling Group
output "autoscaling_group_name" {
  description = "The name of the Autoscaling Group"
  value       = aws_autoscaling_group.main.name
}