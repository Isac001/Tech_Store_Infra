# Output the RDS instance endpoint
output "db_endpoint" {
    description = "The endpoint of the RDS instance"
    value = aws_db_instance.main.endpoint
}

# Output the RDS instance identifier
output "db_instance_identifier" {
    description = "The identifier of the RDS instance"
    value = aws_db_instance.main.id
  
}