# Output the RDS instance endpoint
output "db_endpoint" {
    description = "The endpoint of the RDS instance"
    value = aws_db_instance.main.endpoint
}